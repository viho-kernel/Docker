-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  priority VARCHAR(20) DEFAULT 'medium',
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX idx_tasks_created_at ON tasks(created_at DESC);
CREATE INDEX idx_tasks_completed ON tasks(completed);

-- Insert sample data
INSERT INTO tasks (id, title, description, priority, completed) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Setup Docker environment', 'Configure Docker and Docker Compose for the project', 'high', false),
  ('550e8400-e29b-41d4-a716-446655440002', 'Create React frontend', 'Build React components and pages', 'high', false),
  ('550e8400-e29b-41d4-a716-446655440003', 'Implement API endpoints', 'Build RESTful API with Express', 'high', false),
  ('550e8400-e29b-41d4-a716-446655440004', 'Database optimization', 'Add indexes and optimize queries', 'medium', false),
  ('550e8400-e29b-41d4-a716-446655440005', 'Write documentation', 'Create comprehensive project documentation', 'low', false)
ON CONFLICT DO NOTHING;