const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('postgres://postgres:root@localhost:5432/gymtrack', {
  dialect: 'postgres',
  logging: false, // Desativa logs SQL no console
});

module.exports = sequelize;
