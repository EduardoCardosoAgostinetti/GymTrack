const express = require('express');
const router = express.Router();
const WorkoutEntry = require('../models/WorkoutEntry');
const User = require('../models/user');

// ✅ Criar nova ficha de treino
router.post('/', async (req, res) => {
  try {
    const { userId, group, exerciseName, series } = req.body;

    if (!userId || !group || !exerciseName || !series) {
      return res.status(400).json({ error: 'Campos obrigatórios ausentes.' });
    }

    const entry = await WorkoutEntry.create({
      userId,
      group,
      exerciseName,
      series
    });

    res.status(201).json(entry);
  } catch (error) {
    console.error('Erro ao criar ficha:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

// 📄 Listar todas as fichas de um usuário
router.get('/user/:userId', async (req, res) => {
  try {
    const entries = await WorkoutEntry.findAll({
      where: { userId: req.params.userId },
      order: [['createdAt', 'DESC']]
    });
    res.json(entries);
  } catch (error) {
    console.error('Erro ao listar fichas:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

// 🛠 Atualizar ficha por ID
router.put('/:id', async (req, res) => {
  try {
    const { group, exerciseName, series } = req.body;

    const entry = await WorkoutEntry.findByPk(req.params.id);
    if (!entry) {
      return res.status(404).json({ error: 'Ficha não encontrada.' });
    }

    entry.group = group || entry.group;
    entry.exerciseName = exerciseName || entry.exerciseName;
    entry.series = series || entry.series;

    await entry.save();
    res.json(entry);
  } catch (error) {
    console.error('Erro ao atualizar ficha:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

// ❌ Deletar ficha por ID
router.delete('/:id', async (req, res) => {
  try {
    const entry = await WorkoutEntry.findByPk(req.params.id);
    if (!entry) {
      return res.status(404).json({ error: 'Ficha não encontrada.' });
    }

    await entry.destroy();
    res.json({ message: 'Ficha deletada com sucesso.' });
  } catch (error) {
    console.error('Erro ao deletar ficha:', error);
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

module.exports = router;
