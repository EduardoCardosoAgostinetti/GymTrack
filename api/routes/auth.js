const express = require('express');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
require('dotenv').config();
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const { Op } = require('sequelize');
const router = express.Router();

// Função para gerar token JWT
function generateToken(user) {
  return jwt.sign({ id: user.id, email: user.email }, 'root', { expiresIn: '1h' });
}

// Rota de Registro
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;

  try {
    const userExists = await User.findOne({ where: { email } });
    if (userExists) {
      return res.status(400).json({ message: 'Email já cadastrado!' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await User.create({
      name,
      email,
      password: hashedPassword,
    });

    const token = generateToken(newUser);

    res.status(201).json({ message: 'Usuário registrado com sucesso!', token });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao registrar usuário', error });
  }
});

// Rota de Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(400).json({ message: 'Email não encontrado' });
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(400).json({ message: 'Senha incorreta' });
    }

    const token = generateToken(user);
    res.status(200).json({ message: 'Login bem-sucedido' + user.id, token, userId: user.id });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao fazer login', error });
  }
});

// Rota para obter informações do usuário pelo ID (sem a senha)
router.get('/user/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const user = await User.findOne({
      where: { id },
      attributes: { exclude: ['password'] }, // Exclui a senha
    });

    if (!user) {
      return res.status(404).json({ message: 'Usuário não encontrado' });
    }

    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Erro ao buscar usuário', error });
  }
});

// Atualizar nome
router.put('/user/:id/name', async (req, res) => {
  const { id } = req.params;
  const { name } = req.body;

  try {
    const user = await User.findByPk(id);
    if (!user) return res.status(404).json({ message: 'Usuário não encontrado' });

    await user.update({ name });
    res.status(200).json({ message: 'Nome atualizado com sucesso' });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao atualizar nome', error });
  }
});

// Atualizar email
router.put('/user/:id/email', async (req, res) => {
  const { id } = req.params;
  const { email } = req.body;

  try {
    const user = await User.findByPk(id);
    if (!user) return res.status(404).json({ message: 'Usuário não encontrado' });

    await user.update({ email });
    res.status(200).json({ message: 'Email atualizado com sucesso' });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao atualizar email', error });
  }
});

// Atualizar senha
router.put('/user/:id/password', async (req, res) => {
  const { id } = req.params;
  const { password } = req.body;

  try {
    const user = await User.findByPk(id);
    if (!user) return res.status(404).json({ message: 'Usuário não encontrado' });

    const hashedPassword = await bcrypt.hash(password, 10);
    await user.update({ password: hashedPassword });

    res.status(200).json({ message: 'Senha atualizada com sucesso' });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao atualizar senha', error });
  }
});


// Rota para recuperação de senha (envio de código)
router.post('/forgot', async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(400).json({ message: 'Email não encontrado' });
    }

    // Gerar código de verificação de 6 dígitos
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();

    // Salvar código no banco
    user.verificationCode = verificationCode;
    await user.save();

    // Configurar transporte de email com Gmail (pode ser outro serviço)
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS // Use senha de app, não sua senha normal!
      }
    });

    // Conteúdo do e-mail
    const mailOptions = {
      from: '"Gym Track" <duducom195@gmail.com>',
      to: email,
      subject: 'Código de Verificação - Recuperação de Senha',
      text: `Seu código de verificação é: ${verificationCode}`
    };

    // Enviar email
    await transporter.sendMail(mailOptions);

    res.status(200).json({ message: 'Código de verificação enviado para seu email' });
  } catch (error) {
    console.error('Erro ao enviar email:', error);
    res.status(500).json({ message: 'Erro ao recuperar senha', error });
  }
});

// Rota para verificação de código
router.post('/verify-code', async (req, res) => {
  const { email, code } = req.body;

  try {
    const user = await User.findOne({ where: { email } });
    if (!user || user.verificationCode !== code) {
      return res.status(400).json({ message: 'Código de verificação inválido' });
    }

    // Marcar como verificado
    user.isVerified = true;
    user.verificationCode = null; // Limpar código
    await user.save();

    res.status(200).json({ message: 'Código verificado com sucesso' });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao verificar código', error });
  }
});

// Rota para redefinir a senha
router.post('/reset', async (req, res) => {
  const { email, newPassword } = req.body;

  try {
    const user = await User.findOne({ where: { email, isVerified: true } });
    if (!user) {
      return res.status(400).json({ message: 'Usuário não encontrado ou não verificado' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    await user.save();

    res.status(200).json({ message: 'Senha redefinida com sucesso' });
  } catch (error) {
    res.status(500).json({ message: 'Erro ao redefinir senha', error });
  }
});

module.exports = router;
