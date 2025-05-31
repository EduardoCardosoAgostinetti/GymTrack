const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sequelize = require('./config/database');
const authRoutes = require('./routes/auth');
const workoutRoutes = require('./routes/workout');

const app = express();

// Configurações de middleware
app.use(cors());
app.use(bodyParser.json());

// Rotas
app.use('/auth', authRoutes);
app.use('/workout', workoutRoutes);

// Inicializa o banco de dados e o servidor
sequelize.sync({ alter: true })
  .then(() => {
    console.log('Banco de dados sincronizado');
    app.listen(3000, () => {
      console.log('Servidor rodando na porta 3000');
    });
  })
  .catch((error) => console.error('Erro ao sincronizar banco de dados:', error));
