-- Auto-generated schema from JonLD/jot
-- Last updated: 2025-08-16 00:15:00 UTC
-- Source commit: Manual initial sync

-- Jot Database Schema
-- This schema is automatically synced to dependent repositories
-- Generated from: internal/storage/sqlite.go

CREATE TABLE IF NOT EXISTS notes (
	id TEXT PRIMARY KEY,
	title TEXT NOT NULL,
	path TEXT,
	project TEXT,
	branch TEXT,
	ticket TEXT,
	tags TEXT,
	created_at DATETIME,
	modified_at DATETIME
);