 基于[xxl-job](https://www.xuxueli.com/xxl-job/)

# 概要

xxl-job数据库使用sqllite,用于低依赖测试。

SQLite是一个进程内的库，实现了自给自足的、无服务器的、零配置的、事务性的 SQL 数据库引擎。它是一个零配置的数据库，这意味着与其他数据库不一样，您不需要在系统中配置。

就像其他数据库，SQLite 引擎不是一个独立的进程，可以按应用程序需求进行静态或动态连接。SQLite 直接访问其存储文件。

引入sqllite后我们就不需要依赖Mysql进行部署了。

sqllite性能不能和mysql相对，这个用于**小型项目**低并发的场景还是可以的。

# 部署

下载[可执行代码包](https://github.com/AndsGo/xxl-job-sqllite/releases/download/2.3.1/xxl-job-admin-sqllite-2.3.1.jar)

运行

```shell
java -jar xxl-job-admin-sqllite-2.3.1.jar
```

启动完成后我们就可以在http://127.0.0.1:8080/xxl-job-admin/ 访问`xxl-job` ,登录账号密码 **admin/12345678**



# 主要修改的代码

### **依赖配置`pom.xml`** 

将mysql驱动换成SQLite驱动

```xml
		<!-- mysql -->
<!--		<dependency>-->
<!--			<groupId>mysql</groupId>-->
<!--			<artifactId>mysql-connector-java</artifactId>-->
<!--			<version>${mysql-connector-java.version}</version>-->
<!--		</dependency>-->

		<!-- SQLite 驱动 -->
		<dependency>
			<groupId>org.xerial</groupId>
			<artifactId>sqlite-jdbc</artifactId>
			<version>3.21.0.1</version>
		</dependency>
```

### mybatis sql转换

需要将mysql中的一些语法替换成sqllite,大部分无需修改，少量几个地方需要调整

`XxlJobLogMapper.xml`中的`findFailJobLogIds` `select`需要将`!`替换层`not`

```xml
<select id="findFailJobLogIds" resultType="long" >
    SELECT id FROM `xxl_job_log`
    WHERE Not (
    (trigger_code in (0, 200) and handle_code = 0)
    OR
    (handle_code = 200)
    )
    AND `alarm_status` = 0
    ORDER BY id ASC
    LIMIT #{pagesize}
</select>
```

`XxlJobRegistryMapper.xml`

```xml
<select id="findDead" resultType="java.lang.Integer" >
    SELECT t.id
    FROM xxl_job_registry AS t
    WHERE t.update_time <![CDATA[ < ]]> #{nowTime}
</select>

<select id="findAll"  resultMap="XxlJobRegistry">
    SELECT <include refid="Base_Column_List" />
    FROM xxl_job_registry AS t
    WHERE t.update_time <![CDATA[ > ]]>  #{nowTime}
</select>
```

将对应的算数逻辑放入java代码中

```java
xxlJobRegistryDao.findAll(DateUtil.addSecond(new Date(),-RegistryConfig.DEAD_TIMEOUT))
```

### sql脚本转换

需要将之前的mysql脚本转换为sqllite

```sqlite
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

```

### 自动初始化sqllite

由于sqllite和程序绑定在一起，所有我们可以将sqllite库的创建写入到代码中。

修改`XxlJobAdminApplication.java`代码，增加初始化逻辑

```java
package com.xxl.job.admin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

/**
 * @author xuxueli 2018-10-28 00:38:13
 */
@SpringBootApplication
public class XxlJobAdminApplication {

	public static void main(String[] args){
		// 初始化sqllite
		initSqllite();
        SpringApplication.run(XxlJobAdminApplication.class, args);
	}

	private static void initSqllite(){
		{
			try {
				//获取application.properties 中的配置
				InputStream in = XxlJobAdminApplication.class.getResourceAsStream("/application.properties");
				Properties props = new Properties();
				InputStreamReader inputStreamReader = new InputStreamReader(in, "UTF-8");
				props.load(inputStreamReader);

				Connection conn = null;
				Statement preparedStatement = null;
				Class.forName("org.sqlite.JDBC");
				conn = DriverManager.getConnection(props.getProperty("spring.datasource.url"));
				System.out.println("Opened database successfully");
				preparedStatement = conn.createStatement();;
				ResultSet rs = preparedStatement.executeQuery("SELECT * FROM sqlite_master;");
				while ( rs.next() ) {
					String  name = rs.getString("name");
					if (name.contains("xxl_job_info")){
						// 数据库已经初始化过，跳过
						return;
					}
				}
				// 执行初始化脚本
				preparedStatement.executeUpdate("CREATE TABLE IF NOT EXISTS xxl_job_info (\n" +
						"  id INTEGER PRIMARY KEY AUTOINCREMENT,\n" +
						"  job_group INTEGER NOT NULL,\n" +
						"  job_desc TEXT NOT NULL,\n" +
						"  add_time DATETIME DEFAULT NULL,\n" +
						"  update_time DATETIME DEFAULT NULL,\n" +
						"  author TEXT DEFAULT NULL,\n" +
						"  alarm_email TEXT DEFAULT NULL,\n" +
						"  schedule_type TEXT NOT NULL DEFAULT 'NONE',\n" +
						"  schedule_conf TEXT DEFAULT NULL,\n" +
						"  misfire_strategy TEXT NOT NULL DEFAULT 'DO_NOTHING',\n" +
						"  executor_route_strategy TEXT DEFAULT NULL,\n" +
						"  executor_handler TEXT DEFAULT NULL,\n" +
						"  executor_param TEXT DEFAULT NULL,\n" +
						"  executor_block_strategy TEXT DEFAULT NULL,\n" +
						"  executor_timeout INTEGER NOT NULL DEFAULT 0,\n" +
						"  executor_fail_retry_count INTEGER NOT NULL DEFAULT 0,\n" +
						"  glue_type TEXT NOT NULL,\n" +
						"  glue_source TEXT,\n" +
						"  glue_remark TEXT DEFAULT NULL,\n" +
						"  glue_updatetime DATETIME DEFAULT NULL,\n" +
						"  child_jobid TEXT DEFAULT NULL,\n" +
						"  trigger_status INTEGER NOT NULL DEFAULT 0,\n" +
						"  trigger_last_time INTEGER NOT NULL DEFAULT 0,\n" +
						"  trigger_next_time INTEGER NOT NULL DEFAULT 0\n" +
						");\n" +
						"\n" +
						"-- Create table xxl_job_log\n" +
						"CREATE TABLE IF NOT EXISTS xxl_job_log (\n" +
						"  id INTEGER PRIMARY KEY AUTOINCREMENT,\n" +
						"  job_group INTEGER NOT NULL,\n" +
						"  job_id INTEGER NOT NULL,\n" +
						"  executor_address TEXT DEFAULT NULL,\n" +
						"  executor_handler TEXT DEFAULT NULL,\n" +
						"  executor_param TEXT DEFAULT NULL,\n" +
						"  executor_sharding_param TEXT DEFAULT NULL,\n" +
						"  executor_fail_retry_count INTEGER NOT NULL DEFAULT 0,\n" +
						"  trigger_time DATETIME DEFAULT NULL,\n" +
						"  trigger_code INTEGER NOT NULL,\n" +
						"  trigger_msg TEXT,\n" +
						"  handle_time DATETIME DEFAULT NULL,\n" +
						"  handle_code INTEGER NOT NULL,\n" +
						"  handle_msg TEXT,\n" +
						"  alarm_status INTEGER NOT NULL DEFAULT 0\n" +
						");\n" +
						"\n" +
						"-- Create indexes for xxl_job_log\n" +
						"CREATE INDEX I_trigger_time ON xxl_job_log (trigger_time);\n" +
						"CREATE INDEX I_handle_code ON xxl_job_log (handle_code);\n" +
						"\n" +
						"-- Create table xxl_job_log_report\n" +
						"CREATE TABLE IF NOT EXISTS xxl_job_log_report (\n" +
						"  id INTEGER PRIMARY KEY AUTOINCREMENT,\n" +
						"  trigger_day DATETIME DEFAULT NULL,\n" +
						"  running_count INTEGER NOT NULL DEFAULT 0,\n" +
						"  suc_count INTEGER NOT NULL DEFAULT 0,\n" +
						"  fail_count INTEGER NOT NULL DEFAULT 0,\n" +
						"  update_time DATETIME DEFAULT NULL\n" +
						");\n" +
						"\n" +
						"-- Create unique index for xxl_job_log_report\n" +
						"CREATE UNIQUE INDEX i_trigger_day ON xxl_job_log_report (trigger_day);\n" +
						"\n" +
						"-- Create table xxl_job_logglue\n" +
						"CREATE TABLE IF NOT EXISTS xxl_job_logglue (\n" +
						"  id INTEGER PRIMARY KEY AUTOINCREMENT,\n" +
						"  job_id INTEGER NOT NULL,\n" +
						"  glue_type TEXT DEFAULT NULL,\n" +
						"  glue_source TEXT,\n" +
						"  glue_remark TEXT NOT NULL,\n" +
						"  add_time DATETIME DEFAULT NULL,\n" +
						"  update_time DATETIME DEFAULT NULL\n" +
						");\n" +
						"\n" +
						"-- Create table xxl_job_registry\n" +
						"CREATE TABLE IF NOT EXISTS xxl_job_registry (\n" +
						"  id INTEGER PRIMARY KEY AUTOINCREMENT,\n" +
						"  registry_group TEXT NOT NULL,\n" +
						"  registry_key TEXT NOT NULL,\n" +
						"  registry_value TEXT NOT NULL,\n" +
						"  update_time DATETIME DEFAULT NULL\n" +
						");\n" +
						"\n" +
						"-- Create index for xxl_job_registry\n" +
						"CREATE INDEX i_g_k_v ON xxl_job_registry (registry_group, registry_key, registry_value);\n" +
						"\n" +
						"-- Create table xxl_job_group\n" +
						"CREATE TABLE IF NOT EXISTS xxl_job_group (\n" +
						"  id INTEGER PRIMARY KEY AUTOINCREMENT,\n" +
						"  app_name TEXT NOT NULL,\n" +
						"  title TEXT NOT NULL,\n" +
						"  address_type INTEGER NOT NULL DEFAULT 0,\n" +
						"  address_list TEXT,\n" +
						"  update_time DATETIME DEFAULT NULL\n" +
						");\n" +
						"\n" +
						"-- Create table xxl_job_user\n" +
						"CREATE TABLE xxl_job_user (\n" +
						"  id INTEGER PRIMARY KEY AUTOINCREMENT,\n" +
						"  username TEXT NOT NULL,\n" +
						"  password TEXT NOT NULL,\n" +
						"  role INTEGER NOT NULL,\n" +
						"  permission TEXT DEFAULT NULL\n" +
						");\n" +
						"\n" +
						"-- Create unique index for xxl_job_user\n" +
						"CREATE UNIQUE INDEX i_username ON xxl_job_user (username);\n" +
						"\n" +
						"-- Create table xxl_job_lock\n" +
						"CREATE TABLE xxl_job_lock (\n" +
						"  lock_name TEXT PRIMARY KEY\n" +
						");\n");
				preparedStatement.executeUpdate("INSERT INTO xxl_job_group (id, app_name, title, address_type, address_list, update_time) VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31');\n" +
						"INSERT INTO xxl_job_info (id, job_group, job_desc, add_time, update_time, author, alarm_email, schedule_type, schedule_conf, misfire_strategy, executor_route_strategy, executor_handler, executor_param, executor_block_strategy, executor_timeout, executor_fail_retry_count, glue_type, glue_source, glue_remark, glue_updatetime, child_jobid) VALUES (1, 1, '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'CRON', '0 0 0 * * ? *', 'DO_NOTHING', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化', '2018-11-03 22:21:31', '');\n" +
						"INSERT INTO xxl_job_user (id, username, password, role, permission) VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);\n" +
						"INSERT INTO xxl_job_lock (lock_name) VALUES ('schedule_lock');");
				conn.close();
			} catch ( Exception e ) {
				e.printStackTrace();
				System.exit(0);
			}
			System.out.println("Table created successfully");
		}
	}

}
```

