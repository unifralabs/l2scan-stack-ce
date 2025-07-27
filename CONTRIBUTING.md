# Contributing to L2Scan Stack

Thank you for your interest in contributing to L2Scan Stack! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

### Prerequisites

- Docker Engine 20.10+
- Docker Compose V2
- Node.js 18+ (for frontend development)
- Go 1.19+ (for indexer development)
- Git

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/unifralabs/l2scan-stack-ce.git
   cd l2scan-stack-ce
   ```

2. **Start Development Environment**
   ```bash
   cd docker-compose
   cp .env.example .env
   # Edit .env with your configuration
   make dev
   ```

3. **Verify Setup**
   ```bash
   make health
   ```

## 📝 How to Contribute

### Types of Contributions

- **Bug Reports**: Report issues you encounter
- **Feature Requests**: Suggest new features or improvements
- **Code Contributions**: Submit bug fixes or new features
- **Documentation**: Improve documentation and examples
- **Testing**: Add or improve tests

### Reporting Issues

1. **Search Existing Issues**: Check if the issue already exists
2. **Use Issue Templates**: Fill out the appropriate template
3. **Provide Details**: Include steps to reproduce, expected behavior, and environment info

### Making Changes

1. **Create a Branch**
   ```bash
   git checkout -b feature/unifralabs
   # or
   git checkout -b fix/issue-description
   ```

2. **Make Your Changes**
   - Follow the coding standards
   - Add tests for new features
   - Update documentation as needed

3. **Test Your Changes**
   ```bash
   # Run the stack with your changes
   make dev
   
   # Test health checks
   make health
   
   # Run any additional tests
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add new feature" 
   # or
   git commit -m "fix: resolve issue with ..."
   ```

5. **Push and Create PR**
   ```bash
   git push origin unifralabs
   ```

## 📋 Development Guidelines

### Code Style

#### General
- Use clear, descriptive names for variables, functions, and files
- Write self-documenting code with appropriate comments
- Follow existing patterns and conventions in the codebase

#### Docker and Kubernetes
- Use multi-stage builds for efficiency
- Include health checks in containers
- Follow security best practices (non-root users, minimal images)
- Use semantic versioning for image tags

#### Documentation
- Update README files when adding new features
- Include inline comments for complex logic
- Provide examples for new configuration options

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(helm): add support for external secrets
fix(docker): resolve database connection timeout
docs(readme): update installation instructions
```

### Testing

#### Docker Compose Testing
```bash
# Test production deployment
make clean && make up
make health

# Test development deployment  
make clean && make dev
make health

# Test scaling
docker-compose up -d --scale frontend=2 --scale indexer=2
```

#### Helm Chart Testing
```bash
# Lint chart
helm lint helm-chart/

# Template validation
helm template test helm-chart/ --values helm-chart/values.yaml

# Dry run
helm install test helm-chart/ --dry-run --debug
```

### Pull Request Process

1. **PR Description**
   - Clearly describe what the PR does
   - Reference related issues
   - Include testing instructions
   - Add screenshots for UI changes

2. **PR Requirements**
   - [ ] Tests pass
   - [ ] Documentation updated
   - [ ] No merge conflicts
   - [ ] Follows coding standards

3. **Review Process**
   - Address feedback from reviewers
   - Make requested changes
   - Maintain clean commit history

## 🏗️ Project Structure

```
l2scan-stack-ce/
├── helm-chart/                 # Kubernetes Helm chart
│   ├── templates/             # Kubernetes manifests
│   ├── values.yaml           # Default configuration
│   └── Chart.yaml           # Chart metadata
├── docker-compose/           # Docker Compose setup
│   ├── docker-compose.yml   # Main compose file
│   ├── nginx/               # Nginx configuration
│   └── init-scripts/        # Database init scripts
├── docs/                   # Documentation
└── README.md              # Main documentation
```

## 🔧 Development Environment

### Available Services

When running `make dev`:

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | - |
| Indexer API | http://localhost:8080 | - |
| pgAdmin | http://localhost:8081 | admin@l2scan.com / admin123 |
| Redis Commander | http://localhost:8082 | - |

### Useful Commands

```bash
# View logs
make logs
make frontend-logs
make indexer-logs

# Database operations
make db-backup
make db-restore BACKUP=filename.sql

# Shell access
make shell-frontend
make shell-indexer
make shell-postgres

# Health checks
make health
```

## 🐛 Debugging

### Common Issues

#### Frontend Development
- Check that all environment variables are set correctly
- Verify database connectivity
- Ensure all dependencies are installed

#### Indexer Development
- Verify RPC endpoint is accessible
- Check blockchain network status
- Monitor resource usage

#### Database Issues
- Check PostgreSQL logs: `make postgres-logs`
- Verify connection strings
- Check for migration issues

### Log Analysis

```bash
# Real-time logs for all services
make logs

# Filter logs by service
make frontend-logs | grep ERROR
make indexer-logs | grep WARN

# Export logs for analysis
docker-compose logs --no-color > all-logs.txt
```

## 🚀 Release Process

### Version Numbering

We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

### Creating a Release

1. Update version numbers in:
   - `helm-chart/Chart.yaml`
   - `docker-compose/.env.example`
   - Documentation

2. Update CHANGELOG.md

3. Create and push tag:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

## 🤝 Community

### Getting Help

- **Documentation**: Check the `docs/` directory
- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Ask questions and share ideas

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow the project's guidelines

## 📄 License

By contributing to L2Scan Stack, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- The project's README
- Release notes
- Contributors section

Thank you for contributing to L2Scan Stack! 🎉