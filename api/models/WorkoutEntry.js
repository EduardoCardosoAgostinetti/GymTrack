const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./user');

const WorkoutEntry = sequelize.define('WorkoutEntry', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  group: {
    type: DataTypes.STRING, // Ex: Peito, Costas, Pernas
    allowNull: false,
  },
  exerciseName: {
    type: DataTypes.STRING, // Ex: Supino, Extensora, Agachamento
    allowNull: false,
  },
  series: {
    type: DataTypes.JSON, // Armazena as séries em array
    allowNull: false,
    /**
     * Exemplo:
     * [
     *   { "set": 1, "weight": 20, "reps": 15 },
     *   { "set": 2, "weight": 30, "reps": 12 }
     * ]
     */
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  }
}, {
  tableName: 'workout_entries',
  timestamps: false,
});

WorkoutEntry.belongsTo(User, {
  foreignKey: 'userId',
});
User.hasMany(WorkoutEntry, {
  foreignKey: 'userId',
});


module.exports = WorkoutEntry;
