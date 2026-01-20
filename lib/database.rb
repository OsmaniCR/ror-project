require 'sequel'
require 'bcrypt'

module Database
  def self.connect
    @db ||= Sequel.connect(
      adapter: 'postgres',
      host: ENV['DB_HOST'] || 'localhost',
      port: ENV['DB_PORT'] || 5432,
      database: ENV['DB_NAME'] || 'fudo_db',
      user: ENV['DB_USER'] || 'fudo_user',
      password: ENV['DB_PASSWORD'] || 'fudo_password',
      max_connections: 10
    )
  end

  def self.setup
    db = connect
    
    unless db.table_exists?(:users)
      db.create_table :users do
        primary_key :id
        String :username, unique: true, null: false
        String :password_hash, null: false
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      end
    end
    
    admin_username = ENV['ADMIN_USERNAME'] || 'admin'
    admin_password = ENV['ADMIN_PASSWORD'] || 'admin123'
    
    unless db[:users].where(username: admin_username).first
      password_hash = BCrypt::Password.create(admin_password)
      db[:users].insert(username: admin_username, password_hash: password_hash)
      puts "Created default admin user: #{admin_username}"
    end

    unless db.table_exists?(:products)
      db.create_table :products do
        primary_key :id
        String :name, null: false
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      end
    end

    unless db.table_exists?(:async_jobs)
      db.create_table :async_jobs do
        primary_key :id
        String :name, null: false
        String :status, default: 'pending'
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :processed_at
      end
    end
  end
end
