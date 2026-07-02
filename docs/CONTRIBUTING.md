# Contributing Guide

First off, thank you for considering contributing to **Sovryx OS**! It's people like you that make the open-source community such an amazing place to learn, inspire, and create.

This document outlines the process for contributing to the repository.

---

## 🛠 1. Getting Started

### 1. Fork the Repository
Navigate to the [Sovryx OS GitHub page](#) and click the "Fork" button in the top right corner.

### 2. Clone Your Fork
Clone the repository to your local machine:
```bash
git clone https://github.com/YOUR_USERNAME/sovryx-os.git
cd sovryx-os
```

### 3. Add the Upstream Remote
Connect your local repository to the original upstream repository:
```bash
git remote add upstream https://github.com/sovryxtech/sovryx-os.git
```

---

## 🌿 2. Branching Strategy

Always create a new branch for your work. **Never commit directly to `main` or `develop`.**

1. Fetch the latest changes from upstream:
   ```bash
   git fetch upstream
   ```
2. Create a new branch based on `develop`:
   ```bash
   git checkout -b feature/your-feature-name upstream/develop
   ```
   *(Use `bugfix/your-bug-name` for bug fixes).*

---

## 💻 3. Making Changes & Coding Rules

- Ensure your code adheres to the [Developer Guide](DEVELOPER_GUIDE.md) and PSR-12 coding standards.
- If you are adding a new feature, include the necessary PHPUnit tests (see [Testing Guide](TESTING.md)).
- If you are changing the UI, adhere to the [Style Guide](STYLE_GUIDE.md) and test in both Light and Dark modes.
- Update the documentation (`/docs`) if you introduce new APIs or change existing functionality.

---

## 📝 4. Committing Your Changes

We use the **Conventional Commits** format.

```bash
git add .
git commit -m "feat(crm): add export to csv button for leads list"
```

**Valid Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests

---

## 🚀 5. Submitting a Pull Request (PR)

1. Push your branch to your forked repository on GitHub:
   ```bash
   git push origin feature/your-feature-name
   ```
2. Navigate to the original Sovryx OS repository on GitHub.
3. Click "Compare & pull request".
4. Fill out the PR template completely:
   - Describe what the PR does.
   - Link to any related issue numbers (e.g., `Fixes #123`).
   - Include screenshots if there are UI changes.
5. Submit the PR.

---

## 🔍 6. Review Process

- Automated GitHub Actions will run PHPUnit and CodeSniffer. Your PR **must** pass these checks.
- One of the core maintainers (Developer 1 or Developer 2) will review your code.
- They may request changes. If so, simply make the changes locally, commit, and push them to your branch (the PR will update automatically).
- Once approved, a maintainer will squash and merge your branch into `develop`.

---

🎉 **Thank you for contributing to Sovryx OS!**
