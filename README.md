# Todolist App

A simple and elegant To-Do List application built with Flutter.

## Overview

This project serves as a starting point for building a Flutter application. It provides a clean interface to manage your tasks, with features like task creation, listing, and status updates.

## Features

- **Add tasks**: Quickly add new tasks to your to-do list.
- **Mark tasks as completed**: Keep track of the tasks you've done.
- **Delete tasks**: Easily remove tasks from your list.
- **Cross-platform**: Built with Flutter, so it works on both Android and iOS.

## Getting Started

If you're new to Flutter, follow the instructions below to get started:

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/todolist_app.git
cd todolist_app

### 4. `pubspec.yaml`

Assicurati di avere il file `pubspec.yaml` per gestire le dipendenze, se non l'hai ancora configurato. Ecco un esempio di base:

```yaml
name: todolist_app
description: A simple Flutter To-Do List app
publish_to: 'none' # Remove this line if you are publishing to pub.dev

version: 1.0.0+1

environment:
  sdk: ">=2.18.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter

  # Add any additional dependencies you need here

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
