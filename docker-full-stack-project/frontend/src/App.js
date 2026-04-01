import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';


function App() {
  const [tasks, setTasks] = useState([]);
  const [newTask, setNewTask] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Fetch tasks on component mount
  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/api/tasks`);
      setTasks(response.data);
      setError('');
    } catch (err) {
      setError('Failed to fetch tasks');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const addTask = async (e) => {
    e.preventDefault();
    if (!newTask.trim()) return;

    try {
      const response = await axios.post(`${API_URL}/api/tasks`, {
        title: newTask,
        priority: 'medium'
      });
      setTasks([response.data, ...tasks]);
      setNewTask('');
      setError('');
    } catch (err) {
      setError('Failed to add task');
      console.error(err);
    }
  };

  const toggleTask = async (id, completed) => {
    try {
      const response = await axios.put(`${API_URL}/api/tasks/${id}`, {
        completed: !completed
      });
      setTasks(tasks.map(t => t.id === id ? response.data : t));
      setError('');
    } catch (err) {
      setError('Failed to update task');
      console.error(err);
    }
  };

  const deleteTask = async (id) => {
    try {
      await axios.delete(`${API_URL}/api/tasks/${id}`);
      setTasks(tasks.filter(t => t.id !== id));
      setError('');
    } catch (err) {
      setError('Failed to delete task');
      console.error(err);
    }
  };

  const getPriorityColor = (priority) => {
    const colors = {
      high: '#ff6b6b',
      medium: '#ffd93d',
      low: '#6bcf7f'
    };
    return colors[priority] || '#999';
  };

  return (
    <div className="app">
      <div className="container">
        <h1>📋 Task Manager</h1>

        {error && <div className="error-message">{error}</div>}

        <form onSubmit={addTask} className="add-task-form">
          <input
            type="text"
            value={newTask}
            onChange={(e) => setNewTask(e.target.value)}
            placeholder="Add a new task..."
            className="task-input"
          />
          <button type="submit" className="add-button">Add Task</button>
        </form>

        <div className="tasks-info">
          {tasks.length > 0 && <p>{tasks.length} task{tasks.length !== 1 ? 's' : ''}</p>}
        </div>

        {loading ? (
          <div className="loading">Loading tasks...</div>
        ) : tasks.length === 0 ? (
          <div className="empty-state">
            <p>No tasks yet. Add one to get started! 🚀</p>
          </div>
        ) : (
          <ul className="tasks-list">
            {tasks.map(task => (
              <li key={task.id} className={`task-item ${task.completed ? 'completed' : ''}`}>
                <div className="task-content">
                  <input
                    type="checkbox"
                    checked={task.completed}
                    onChange={() => toggleTask(task.id, task.completed)}
                    className="task-checkbox"
                  />
                  <div className="task-text">
                    <h3>{task.title}</h3>
                    {task.description && <p>{task.description}</p>}
                  </div>
                  <span 
                    className="priority-badge"
                    style={{ backgroundColor: getPriorityColor(task.priority) }}
                  >
                    {task.priority}
                  </span>
                </div>
                <button
                  onClick={() => deleteTask(task.id)}
                  className="delete-button"
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}

export default App;