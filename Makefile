.PHONY: db fakes

db:
	@echo "🧨 Dropping database if exists..."
	@sudo -u postgres psql -c "DROP DATABASE IF EXISTS projectpulse;"

	@echo "🚀 Creating database projectpulse..."
	@sudo -u postgres psql -c "CREATE DATABASE projectpulse WITH OWNER = postgres ENCODING = 'UTF8' LOCALE_PROVIDER = icu ICU_LOCALE = 'en-US' TEMPLATE = template0;"

	@echo "📦 Applying data model from quest_1_Data_Modeling.sql..."
	@sudo -u postgres psql -d projectpulse -f src/sql/quest_1_Data_Modeling.sql

	@echo "🧠 Creating database via quest_2_SQL_Role_Based_Access_Control.sql..."
	@sudo -u postgres psql -d projectpulse -f src/sql/quest_2_SQL_Role_Based_Access_Control.sql

	@echo "⚙️ Applying DBMS performance config from quest_3_DBMS_Performance.sql..."
	@sudo -u postgres psql -d projectpulse -f src/sql/quest_3_DBMS_Performance.sql

	@echo "🧩 Installing optional extensions from optional_extensions.sql..."
	@sudo -u postgres psql -d projectpulse -f src/sql/optional_extensions.sql

	@echo ""
	@echo "✅ Database creation complete!"
	@echo ""


fakes:
	@echo "🔧 Checking Poetry installation..."
	@which poetry > /dev/null || curl -sSL https://install.python-poetry.org | python3 -
	@echo "✅ Poetry is installed or already available"
	@echo "📦 Installing dependencies with dev group..."
	@poetry install --with dev
	@echo "🧪 Running tests with coverage..."
	@PYTHONPATH=. poetry run pytest --cov=src --cov-report=term --cov-report=html
	@echo "🚀 Running the fake data generator..."
	@PYTHONPATH=. poetry run python src/scripts/quest_4_Generate_Fake_Data.py
