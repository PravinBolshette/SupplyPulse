.PHONY: help install test lint run-api run-dashboard up down clean

help:
	@echo "SupplyPulse Management Commands:"
	@echo "  make install        Install base and dev dependencies"
	@echo "  make test           Run test suite with pytest"
	@echo "  make lint           Check code quality with flake8 and black"
	@echo "  make up             Start postgres service via Docker Compose"
	@echo "  make down           Stop docker containers"
	@echo "  make run-api        Start FastAPI server"
	@echo "  make run-dashboard  Start Streamlit dashboard"
	@echo "  make clean          Clean cache and temporary files"

install:
	pip install -r requirements/base.txt -r requirements/dev.txt

test:
	pytest tests/

lint:
	flake8 src/ tests/
	black --check src/ tests/

up:
	docker-compose up -d

down:
	docker-compose down

run-api:
	uvicorn src.supplypulse.api.main:app --host 0.0.0.0 --port 8000 --reload

run-dashboard:
	streamlit run src/supplypulse/dashboard/app.py --server.port 8050

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
