-- XXL-JOB v2.3.1
-- Copyright (c) 2015-present, xuxueli.

-- SQLite does not support CREATE DATABASE or USE statements.
-- So, we skip the CREATE DATABASE and USE statements.

-- Set the character encoding
PRAGMA encoding = "UTF-8";

-- Create table xxl_job_info
CREATE TABLE IF NOT EXISTS xxl_job_info (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_group INTEGER NOT NULL,
  job_desc TEXT NOT NULL,
  add_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  author TEXT DEFAULT NULL,
  alarm_email TEXT DEFAULT NULL,
  schedule_type TEXT NOT NULL DEFAULT 'NONE',
  schedule_conf TEXT DEFAULT NULL,
  misfire_strategy TEXT NOT NULL DEFAULT 'DO_NOTHING',
  executor_route_strategy TEXT DEFAULT NULL,
  executor_handler TEXT DEFAULT NULL,
  executor_param TEXT DEFAULT NULL,
  executor_block_strategy TEXT DEFAULT NULL,
  executor_timeout INTEGER NOT NULL DEFAULT 0,
  executor_fail_retry_count INTEGER NOT NULL DEFAULT 0,
  glue_type TEXT NOT NULL,
  glue_source TEXT,
  glue_remark TEXT DEFAULT NULL,
  glue_updatetime DATETIME DEFAULT NULL,
  child_jobid TEXT DEFAULT NULL,
  trigger_status INTEGER NOT NULL DEFAULT 0,
  trigger_last_time INTEGER NOT NULL DEFAULT 0,
  trigger_next_time INTEGER NOT NULL DEFAULT 0
);

-- Create table xxl_job_log
CREATE TABLE IF NOT EXISTS xxl_job_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_group INTEGER NOT NULL,
  job_id INTEGER NOT NULL,
  executor_address TEXT DEFAULT NULL,
  executor_handler TEXT DEFAULT NULL,
  executor_param TEXT DEFAULT NULL,
  executor_sharding_param TEXT DEFAULT NULL,
  executor_fail_retry_count INTEGER NOT NULL DEFAULT 0,
  trigger_time DATETIME DEFAULT NULL,
  trigger_code INTEGER NOT NULL,
  trigger_msg TEXT,
  handle_time DATETIME DEFAULT NULL,
  handle_code INTEGER NOT NULL,
  handle_msg TEXT,
  alarm_status INTEGER NOT NULL DEFAULT 0
);

-- Create indexes for xxl_job_log
CREATE INDEX I_trigger_time ON xxl_job_log (trigger_time);
CREATE INDEX I_handle_code ON xxl_job_log (handle_code);

-- Create table xxl_job_log_report
CREATE TABLE IF NOT EXISTS xxl_job_log_report (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  trigger_day DATETIME DEFAULT NULL,
  running_count INTEGER NOT NULL DEFAULT 0,
  suc_count INTEGER NOT NULL DEFAULT 0,
  fail_count INTEGER NOT NULL DEFAULT 0,
  update_time DATETIME DEFAULT NULL
);

-- Create unique index for xxl_job_log_report
CREATE UNIQUE INDEX i_trigger_day ON xxl_job_log_report (trigger_day);

-- Create table xxl_job_logglue
CREATE TABLE IF NOT EXISTS xxl_job_logglue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_id INTEGER NOT NULL,
  glue_type TEXT DEFAULT NULL,
  glue_source TEXT,
  glue_remark TEXT NOT NULL,
  add_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL
);

-- Create table xxl_job_registry
CREATE TABLE IF NOT EXISTS xxl_job_registry (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  registry_group TEXT NOT NULL,
  registry_key TEXT NOT NULL,
  registry_value TEXT NOT NULL,
  update_time DATETIME DEFAULT NULL
);

-- Create index for xxl_job_registry
CREATE INDEX i_g_k_v ON xxl_job_registry (registry_group, registry_key, registry_value);

-- Create table xxl_job_group
CREATE TABLE IF NOT EXISTS xxl_job_group (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  app_name TEXT NOT NULL,
  title TEXT NOT NULL,
  address_type INTEGER NOT NULL DEFAULT 0,
  address_list TEXT,
  update_time DATETIME DEFAULT NULL
);

-- Create table xxl_job_user
CREATE TABLE xxl_job_user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  role INTEGER NOT NULL,
  permission TEXT DEFAULT NULL
);

-- Create unique index for xxl_job_user
CREATE UNIQUE INDEX i_username ON xxl_job_user (username);

-- Create table xxl_job_lock
CREATE TABLE xxl_job_lock (
  lock_name TEXT PRIMARY KEY
);

-- Insert initial data
INSERT INTO xxl_job_group (id, app_name, title, address_type, address_list, update_time) VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31');
INSERT INTO xxl_job_info (id, job_group, job_desc, add_time, update_time, author, alarm_email, schedule_type, schedule_conf, misfire_strategy, executor_route_strategy, executor_handler, executor_param, executor_block_strategy, executor_timeout, executor_fail_retry_count, glue_type, glue_source, glue_remark, glue_updatetime, child_jobid) VALUES (1, 1, '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'CRON', '0 0 0 * * ? *', 'DO_NOTHING', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化', '2018-11-03 22:21:31', '');
INSERT INTO xxl_job_user (id, username, password, role, permission) VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
INSERT INTO xxl_job_lock (lock_name) VALUES ('schedule_lock');

-- Commit transaction
COMMIT;
