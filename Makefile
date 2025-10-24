.PHONY: generate_fakes

generate_fakes:
	@echo "🔧 Checking Poetry installation..."
	@which poetry > /dev/null || curl -sSL https://install.python-poetry.org | python3 -
	@echo "✅ Poetry is installed or already available"

	@echo "📦 Installing dependencies with dev group..."
	@poetry install --with dev

	@echo "🧪 Running tests with coverage..."
	@PYTHONPATH=. poetry run pytest --cov=src --cov-report=term --cov-report=html

	@echo "🚀 Running the fake data generator..."
	@PYTHONPATH=. poetry run python src/scripts/quest_4_Generate_Fake_Data.py
