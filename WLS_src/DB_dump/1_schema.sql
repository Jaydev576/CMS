-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: wls
-- ------------------------------------------------------
-- Server version	8.0.45-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `wls`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `wls` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `wls`;

--
-- Table structure for table `admin_content_review_remarks`
--

DROP TABLE IF EXISTS `admin_content_review_remarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_content_review_remarks` (
  `remark_id` bigint NOT NULL AUTO_INCREMENT,
  `content_type` varchar(50) NOT NULL,
  `composite_id` varchar(255) NOT NULL,
  `remarks` text,
  `admin_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`remark_id`),
  UNIQUE KEY `uq_review_remarks_content` (`content_type`,`composite_id`),
  KEY `idx_review_remarks_admin` (`admin_user_id`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_privilege_audit`
--

DROP TABLE IF EXISTS `admin_privilege_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_privilege_audit` (
  `audit_id` bigint NOT NULL AUTO_INCREMENT,
  `admin_user_id` int NOT NULL,
  `target_user_id` int NOT NULL,
  `privilege_type` varchar(50) NOT NULL,
  `subject_id` int DEFAULT NULL,
  `chapter_id` int DEFAULT NULL,
  `action` varchar(20) NOT NULL,
  `changes_json` text,
  `actioned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`),
  KEY `idx_admin_priv_audit_target` (`target_user_id`,`actioned_at`),
  KEY `idx_admin_priv_audit_subject` (`subject_id`,`actioned_at`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_routes`
--

DROP TABLE IF EXISTS `api_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_routes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `route_path` varchar(100) NOT NULL,
  `servlet_name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `route_path` (`route_path`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audio`
--

DROP TABLE IF EXISTS `audio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audio` (
  `audio_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `audio_id` int NOT NULL,
  `audio_name` varchar(200) DEFAULT NULL,
  `audio_url` varchar(200) DEFAULT NULL,
  `audio` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`audio_id`),
  KEY `idx_audio_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_audio` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chapter`
--

DROP TABLE IF EXISTS `chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chapter` (
  `chapter_cd` varchar(8) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `chapter_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`),
  KEY `idx_chapter_subject` (`subject_id`,`chapter_id`),
  KEY `idx_chapter_cd` (`chapter_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_chapter` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class`
--

DROP TABLE IF EXISTS `class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class` (
  `class_cd` varchar(22) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `class_name` varchar(200) DEFAULT NULL,
  `co_ordinator` varchar(50) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `room_no` varchar(5) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`class_id`,`specialization_id`),
  KEY `fk_class` (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`),
  CONSTRAINT `fk_class` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`) REFERENCES `specialization` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject`
--

DROP TABLE IF EXISTS `class_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject` (
  `class_subject_cd` varchar(27) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`),
  KEY `fk2_class_subject` (`subject_id`),
  KEY `idx_class_subject_class` (`class_id`,`subject_id`),
  KEY `idx_class_subject_subject` (`subject_id`),
  CONSTRAINT `fk1_class_subject` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject_chapter`
--

DROP TABLE IF EXISTS `class_subject_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject_chapter` (
  `class_subject_chapter_cd` varchar(29) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`,`chapter_id`),
  KEY `fk2_class_subject_chapter` (`subject_id`,`chapter_id`),
  CONSTRAINT `fk1_class_subject_chapter` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_subject_chapter` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject_chapter_topic_level1`
--

DROP TABLE IF EXISTS `class_subject_chapter_topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject_chapter_topic_level1` (
  `class_subject_chapter_topic_level1_cd` varchar(31) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `fk2_class_subject_chapter_topic_level1` (`subject_id`,`chapter_id`,`topic_level1_id`),
  CONSTRAINT `fk1_class_subject_chapter_topic_level1` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_subject_chapter_topic_level1` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject_chapter_topic_level1_topic_level2`
--

DROP TABLE IF EXISTS `class_subject_chapter_topic_level1_topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject_chapter_topic_level1_topic_level2` (
  `class_subject_chapter_topic_level1_topic_level2_cd` varchar(33) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `fk2_class_topic_level2` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk1_class_topic_level2` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_topic_level2` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_chapter`
--

DROP TABLE IF EXISTS `content_developer_privileges_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_chapter` (
  `content_developer_priveleges_chapter_cd` varchar(12) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`),
  KEY `fk2_content_developer_priveleges_chapter` (`subject_id`,`chapter_id`),
  CONSTRAINT `fk1_content_developer_priveleges_chapter` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_chapter` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_subject`
--

DROP TABLE IF EXISTS `content_developer_privileges_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_subject` (
  `content_developer_priveleges_subject_cd` varchar(10) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`),
  KEY `fk2_content_developer_priveleges_subject` (`subject_id`),
  CONSTRAINT `fk1_content_developer_priveleges_subject` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_topic_level1`
--

DROP TABLE IF EXISTS `content_developer_privileges_topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_topic_level1` (
  `content_developer_priveleges_topic_level1_cd` varchar(14) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `fk2_content_developer_priveleges_topic_level1_id` (`subject_id`,`chapter_id`,`topic_level1_id`),
  CONSTRAINT `fk1_content_developer_priveleges_topic_level1_id` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_topic_level1_id` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_topic_level2`
--

DROP TABLE IF EXISTS `content_developer_privileges_topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_topic_level2` (
  `content_developer_priveleges_topic_level2_cd` varchar(16) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `fk2_content_developer_priveleges_topic_level2_id` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk1_content_developer_priveleges_topic_level2_id` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_topic_level2_id` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_users`
--

DROP TABLE IF EXISTS `content_developer_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_users` (
  `user_id` int NOT NULL,
  `university_id` int DEFAULT NULL,
  `faculty_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `nationality_id` int DEFAULT '1',
  PRIMARY KEY (`user_id`),
  KEY `fk1_content_developer_users` (`university_id`,`faculty_id`,`department_id`,`course_id`),
  KEY `fk3_content_developer_users` (`nationality_id`),
  CONSTRAINT `fk1_content_developer_users` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`) REFERENCES `course` (`university_id`, `faculty_id`, `department_id`, `course_id`),
  CONSTRAINT `fk2_content_developer_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk3_content_developer_users` FOREIGN KEY (`nationality_id`) REFERENCES `country_list` (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_class_enrollment`
--

DROP TABLE IF EXISTS `content_viewer_class_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_class_enrollment` (
  `enrollment_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `enrollment_type` enum('HOME','EXPLICIT') NOT NULL DEFAULT 'EXPLICIT',
  `status` enum('PENDING','ACTIVE','REVOKED','EXPIRED') NOT NULL DEFAULT 'ACTIVE',
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `uq_content_viewer_class_enrollment` (`user_id`,`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`),
  KEY `idx_cvce_user_status` (`user_id`,`status`,`valid_from`,`valid_to`),
  KEY `idx_cvce_class` (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`),
  KEY `idx_cvce_granted_by` (`granted_by`),
  CONSTRAINT `fk_cvce_class` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk_cvce_granted_by` FOREIGN KEY (`granted_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_cvce_user` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_chapter`
--

DROP TABLE IF EXISTS `content_viewer_privileges_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_chapter` (
  `content_viewer_priveleges_chapter_cd` varchar(12) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`),
  KEY `fk2_content_viewer_priveleges_chapter` (`subject_id`,`chapter_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_chapter` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_chapter` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_subject`
--

DROP TABLE IF EXISTS `content_viewer_privileges_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_subject` (
  `content_viewer_priveleges_subject_cd` varchar(10) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`),
  KEY `fk2_content_viewer_priveleges_subject` (`subject_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_subject` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_topic_level1`
--

DROP TABLE IF EXISTS `content_viewer_privileges_topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_topic_level1` (
  `content_viewer_priveleges_topic_level1_cd` varchar(14) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `fk2_content_viewer_priveleges_topic_level1` (`subject_id`,`chapter_id`,`topic_level1_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_topic_level1` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_topic_level1` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_topic_level2`
--

DROP TABLE IF EXISTS `content_viewer_privileges_topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_topic_level2` (
  `content_viewer_priveleges_topic_level2_cd` varchar(16) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `fk2_content_viewer_priveleges_topic_level2` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_topic_level2` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_topic_level2` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_users`
--

DROP TABLE IF EXISTS `content_viewer_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_users` (
  `user_id` int NOT NULL,
  `university_id` int DEFAULT NULL,
  `faculty_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `specialization_id` int DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  `nationality_id` int DEFAULT '1',
  PRIMARY KEY (`user_id`),
  KEY `fk1_content_viewer_users` (`university_id`,`faculty_id`,`department_id`,`course_id`),
  KEY `fk3_content_viewer_users` (`nationality_id`),
  KEY `idx_viewer_user` (`user_id`),
  KEY `idx_viewer_class` (`class_id`),
  CONSTRAINT `fk1_content_viewer_users` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`) REFERENCES `course` (`university_id`, `faculty_id`, `department_id`, `course_id`),
  CONSTRAINT `fk2_content_viewer_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk3_content_viewer_users` FOREIGN KEY (`nationality_id`) REFERENCES `country_list` (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `country_list`
--

DROP TABLE IF EXISTS `country_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `country_list` (
  `country_id` int NOT NULL,
  `country_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course` (
  `course_cd` varchar(16) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `course_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `co_ordinator` varchar(50) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`),
  CONSTRAINT `fk_course` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`) REFERENCES `department` (`university_id`, `faculty_id`, `department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department` (
  `department_cd` varchar(13) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `department_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `hod` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `contact_no` varchar(15) DEFAULT NULL,
  `fax_no` varchar(15) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`),
  CONSTRAINT `fk_department` FOREIGN KEY (`university_id`, `faculty_id`) REFERENCES `faculty` (`university_id`, `faculty_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `faculty_cd` varchar(7) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `faculty_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `dean` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `contact_no` varchar(15) DEFAULT NULL,
  `fax_no` varchar(15) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`),
  CONSTRAINT `fk_faculty` FOREIGN KEY (`university_id`) REFERENCES `university` (`university_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image`
--

DROP TABLE IF EXISTS `image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `image` (
  `image_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `image_id` int NOT NULL,
  `image_name` varchar(200) DEFAULT NULL,
  `image_url` varchar(200) DEFAULT NULL,
  `image` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`image_id`),
  KEY `idx_image_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_image` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `learning_content`
--

DROP TABLE IF EXISTS `learning_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_content` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content_type` varchar(32) NOT NULL,
  `resource_url` text NOT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `privileges`
--

DROP TABLE IF EXISTS `privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `privileges` (
  `user_id` int NOT NULL,
  `privilege_level` int NOT NULL,
  `privilege_no` int NOT NULL,
  `university_id` int DEFAULT NULL,
  `faculty_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `specialization_id` int DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  PRIMARY KEY (`user_id`,`privilege_level`,`privilege_no`),
  CONSTRAINT `FKuser_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `program`
--

DROP TABLE IF EXISTS `program`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `program` (
  `program_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `program_id` int NOT NULL,
  `program_name` varchar(200) DEFAULT NULL,
  `program_url` varchar(200) DEFAULT NULL,
  `program` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`program_id`),
  KEY `idx_program_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_program` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_roles_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `simulation`
--

DROP TABLE IF EXISTS `simulation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `simulation` (
  `simulation_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `simulation_id` int NOT NULL,
  `jar_file_name` varchar(200) DEFAULT NULL,
  `class_name` varchar(200) DEFAULT NULL,
  `jsp_file_name` varchar(200) DEFAULT NULL,
  `option_id` int DEFAULT NULL,
  `url` longtext,
  `simulation` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`simulation_id`),
  KEY `idx_simulation_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_simulation` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `specialization`
--

DROP TABLE IF EXISTS `specialization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `specialization` (
  `specialization_cd` varchar(19) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `specialization_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `co_ordinator` varchar(45) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`),
  CONSTRAINT `fk_specialization` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`) REFERENCES `course` (`university_id`, `faculty_id`, `department_id`, `course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject`
--

DROP TABLE IF EXISTS `subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject` (
  `subject_id` int NOT NULL,
  `subject_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `subject_code` varchar(50) DEFAULT NULL,
  `description` text,
  `credit_hours` int DEFAULT NULL,
  `semester_no` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_appendix`
--

DROP TABLE IF EXISTS `subject_appendix`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_appendix` (
  `subject_appendix_cd` varchar(10) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `appendix_id` int NOT NULL,
  `content` longtext,
  PRIMARY KEY (`subject_id`,`appendix_id`),
  CONSTRAINT `fk_subject_appendix` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_exercise`
--

DROP TABLE IF EXISTS `subject_exercise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_exercise` (
  `subject_exercise_cd` varchar(10) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `exercise_id` int NOT NULL,
  `content` longtext,
  PRIMARY KEY (`subject_id`,`exercise_id`),
  CONSTRAINT `fk_subject_exercise` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_glossary`
--

DROP TABLE IF EXISTS `subject_glossary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_glossary` (
  `subject_glossary_cd` varchar(12) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int DEFAULT NULL,
  `topic_level2_id` int DEFAULT NULL,
  `topic_level3_id` int DEFAULT NULL,
  `topic_level4_id` int DEFAULT NULL,
  `topic_level5_id` int DEFAULT NULL,
  `keyword_id` int NOT NULL,
  `keyword_name` varchar(200) DEFAULT NULL,
  `Keyword_link` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`keyword_id`),
  CONSTRAINT `fk_subject_glossary` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_index`
--

DROP TABLE IF EXISTS `subject_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_index` (
  `subject_index_cd` varchar(14) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `index_id` int NOT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`index_id`),
  CONSTRAINT `fk_index` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_references`
--

DROP TABLE IF EXISTS `subject_references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_references` (
  `subject_references_cd` varchar(10) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `reference_id` int NOT NULL,
  `reference_name` varchar(200) DEFAULT NULL,
  `reference_location` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`reference_id`),
  CONSTRAINT `fk_subject_references` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_solutions`
--

DROP TABLE IF EXISTS `subject_solutions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_solutions` (
  `subject_solutions_cd` varchar(15) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `exercise_id` int NOT NULL,
  `solution_id` int NOT NULL,
  `content` longtext,
  PRIMARY KEY (`subject_id`,`exercise_id`,`solution_id`),
  CONSTRAINT `fk_subject_solutions` FOREIGN KEY (`subject_id`, `exercise_id`) REFERENCES `subject_exercise` (`subject_id`, `exercise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level1`
--

DROP TABLE IF EXISTS `topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level1` (
  `topic_level1_cd` varchar(11) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level1_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `idx_topic1_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `idx_topic1_cd` (`topic_level1_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level1` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level2`
--

DROP TABLE IF EXISTS `topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level2` (
  `topic_level2_cd` varchar(14) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level2_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `idx_topic2_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `idx_topic2_cd` (`topic_level2_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level2` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level3`
--

DROP TABLE IF EXISTS `topic_level3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level3` (
  `topic_level3_cd` varchar(17) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level3_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`),
  KEY `idx_topic3_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`),
  KEY `idx_topic3_cd` (`topic_level3_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level3` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level4`
--

DROP TABLE IF EXISTS `topic_level4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level4` (
  `topic_level4_cd` varchar(20) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level4_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`),
  KEY `idx_topic4_cd` (`topic_level4_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level4` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`) REFERENCES `topic_level3` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level5`
--

DROP TABLE IF EXISTS `topic_level5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level5` (
  `topic_level5_cd` varchar(23) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `topic_level5_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`),
  KEY `idx_topic5_cd` (`topic_level5_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level5` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`, `topic_level4_id`) REFERENCES `topic_level4` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`, `topic_level4_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `university`
--

DROP TABLE IF EXISTS `university`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `university` (
  `university_id` int NOT NULL,
  `aicte_id` varchar(15) DEFAULT NULL,
  `university_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `vice_chancellor` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `contact_no` int DEFAULT NULL,
  `fax_no` int DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role_id` int NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `mobile_no` varchar(15) DEFAULT NULL,
  `password_updated_at` timestamp NULL DEFAULT NULL,
  `failed_login_attempts` int DEFAULT '0',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `account_status` varchar(50) DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_users_username` (`username`),
  KEY `fk_users_role` (`role_id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `video`
--

DROP TABLE IF EXISTS `video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `video` (
  `video_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `video_id` int NOT NULL,
  `video_name` varchar(200) DEFAULT NULL,
  `video_url` varchar(200) DEFAULT NULL,
  `video` longblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`video_id`),
  KEY `idx_video_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_video` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Current Database: `wls`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `wls` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `wls`;

--
-- Table structure for table `admin_content_review_remarks`
--

DROP TABLE IF EXISTS `admin_content_review_remarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_content_review_remarks` (
  `remark_id` bigint NOT NULL AUTO_INCREMENT,
  `content_type` varchar(50) NOT NULL,
  `composite_id` varchar(255) NOT NULL,
  `remarks` text,
  `admin_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`remark_id`),
  UNIQUE KEY `uq_review_remarks_content` (`content_type`,`composite_id`),
  KEY `idx_review_remarks_admin` (`admin_user_id`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_privilege_audit`
--

DROP TABLE IF EXISTS `admin_privilege_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_privilege_audit` (
  `audit_id` bigint NOT NULL AUTO_INCREMENT,
  `admin_user_id` int NOT NULL,
  `target_user_id` int NOT NULL,
  `privilege_type` varchar(50) NOT NULL,
  `subject_id` int DEFAULT NULL,
  `chapter_id` int DEFAULT NULL,
  `action` varchar(20) NOT NULL,
  `changes_json` text,
  `actioned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`),
  KEY `idx_admin_priv_audit_target` (`target_user_id`,`actioned_at`),
  KEY `idx_admin_priv_audit_subject` (`subject_id`,`actioned_at`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_routes`
--

DROP TABLE IF EXISTS `api_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_routes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `route_path` varchar(100) NOT NULL,
  `servlet_name` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `route_path` (`route_path`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audio`
--

DROP TABLE IF EXISTS `audio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audio` (
  `audio_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `audio_id` int NOT NULL,
  `audio_name` varchar(200) DEFAULT NULL,
  `audio_url` varchar(200) DEFAULT NULL,
  `audio` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`audio_id`),
  KEY `idx_audio_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_audio` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chapter`
--

DROP TABLE IF EXISTS `chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chapter` (
  `chapter_cd` varchar(8) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `chapter_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`),
  KEY `idx_chapter_subject` (`subject_id`,`chapter_id`),
  KEY `idx_chapter_cd` (`chapter_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_chapter` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class`
--

DROP TABLE IF EXISTS `class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class` (
  `class_cd` varchar(22) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `class_name` varchar(200) DEFAULT NULL,
  `co_ordinator` varchar(50) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `room_no` varchar(5) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`class_id`,`specialization_id`),
  KEY `fk_class` (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`),
  CONSTRAINT `fk_class` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`) REFERENCES `specialization` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject`
--

DROP TABLE IF EXISTS `class_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject` (
  `class_subject_cd` varchar(27) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`),
  KEY `fk2_class_subject` (`subject_id`),
  KEY `idx_class_subject_class` (`class_id`,`subject_id`),
  KEY `idx_class_subject_subject` (`subject_id`),
  CONSTRAINT `fk1_class_subject` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject_chapter`
--

DROP TABLE IF EXISTS `class_subject_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject_chapter` (
  `class_subject_chapter_cd` varchar(29) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`,`chapter_id`),
  KEY `fk2_class_subject_chapter` (`subject_id`,`chapter_id`),
  CONSTRAINT `fk1_class_subject_chapter` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_subject_chapter` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject_chapter_topic_level1`
--

DROP TABLE IF EXISTS `class_subject_chapter_topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject_chapter_topic_level1` (
  `class_subject_chapter_topic_level1_cd` varchar(31) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `fk2_class_subject_chapter_topic_level1` (`subject_id`,`chapter_id`,`topic_level1_id`),
  CONSTRAINT `fk1_class_subject_chapter_topic_level1` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_subject_chapter_topic_level1` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_subject_chapter_topic_level1_topic_level2`
--

DROP TABLE IF EXISTS `class_subject_chapter_topic_level1_topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_subject_chapter_topic_level1_topic_level2` (
  `class_subject_chapter_topic_level1_topic_level2_cd` varchar(33) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `semester_no` int DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT NULL,
  `effective_from` date DEFAULT NULL,
  `effective_to` date DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`,`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `fk2_class_topic_level2` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk1_class_topic_level2` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk2_class_topic_level2` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_chapter`
--

DROP TABLE IF EXISTS `content_developer_privileges_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_chapter` (
  `content_developer_priveleges_chapter_cd` varchar(12) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`),
  KEY `fk2_content_developer_priveleges_chapter` (`subject_id`,`chapter_id`),
  CONSTRAINT `fk1_content_developer_priveleges_chapter` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_chapter` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_subject`
--

DROP TABLE IF EXISTS `content_developer_privileges_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_subject` (
  `content_developer_priveleges_subject_cd` varchar(10) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`),
  KEY `fk2_content_developer_priveleges_subject` (`subject_id`),
  CONSTRAINT `fk1_content_developer_priveleges_subject` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_topic_level1`
--

DROP TABLE IF EXISTS `content_developer_privileges_topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_topic_level1` (
  `content_developer_priveleges_topic_level1_cd` varchar(14) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `fk2_content_developer_priveleges_topic_level1_id` (`subject_id`,`chapter_id`,`topic_level1_id`),
  CONSTRAINT `fk1_content_developer_priveleges_topic_level1_id` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_topic_level1_id` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_privileges_topic_level2`
--

DROP TABLE IF EXISTS `content_developer_privileges_topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_privileges_topic_level2` (
  `content_developer_priveleges_topic_level2_cd` varchar(16) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `write_permission` char(1) DEFAULT NULL,
  `edit_permission` char(1) DEFAULT NULL,
  `review_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `fk2_content_developer_priveleges_topic_level2_id` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk1_content_developer_priveleges_topic_level2_id` FOREIGN KEY (`user_id`) REFERENCES `content_developer_users` (`user_id`),
  CONSTRAINT `fk2_content_developer_priveleges_topic_level2_id` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_developer_users`
--

DROP TABLE IF EXISTS `content_developer_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_developer_users` (
  `user_id` int NOT NULL,
  `university_id` int DEFAULT NULL,
  `faculty_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `nationality_id` int DEFAULT '1',
  PRIMARY KEY (`user_id`),
  KEY `fk1_content_developer_users` (`university_id`,`faculty_id`,`department_id`,`course_id`),
  KEY `fk3_content_developer_users` (`nationality_id`),
  CONSTRAINT `fk1_content_developer_users` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`) REFERENCES `course` (`university_id`, `faculty_id`, `department_id`, `course_id`),
  CONSTRAINT `fk2_content_developer_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk3_content_developer_users` FOREIGN KEY (`nationality_id`) REFERENCES `country_list` (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_class_enrollment`
--

DROP TABLE IF EXISTS `content_viewer_class_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_class_enrollment` (
  `enrollment_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `class_id` int NOT NULL,
  `enrollment_type` enum('HOME','EXPLICIT') NOT NULL DEFAULT 'EXPLICIT',
  `status` enum('PENDING','ACTIVE','REVOKED','EXPIRED') NOT NULL DEFAULT 'ACTIVE',
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `uq_content_viewer_class_enrollment` (`user_id`,`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`),
  KEY `idx_cvce_user_status` (`user_id`,`status`,`valid_from`,`valid_to`),
  KEY `idx_cvce_class` (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`,`class_id`),
  KEY `idx_cvce_granted_by` (`granted_by`),
  CONSTRAINT `fk_cvce_class` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`) REFERENCES `class` (`university_id`, `faculty_id`, `department_id`, `course_id`, `specialization_id`, `class_id`),
  CONSTRAINT `fk_cvce_granted_by` FOREIGN KEY (`granted_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_cvce_user` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_chapter`
--

DROP TABLE IF EXISTS `content_viewer_privileges_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_chapter` (
  `content_viewer_priveleges_chapter_cd` varchar(12) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`),
  KEY `fk2_content_viewer_priveleges_chapter` (`subject_id`,`chapter_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_chapter` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_chapter` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_subject`
--

DROP TABLE IF EXISTS `content_viewer_privileges_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_subject` (
  `content_viewer_priveleges_subject_cd` varchar(10) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`),
  KEY `fk2_content_viewer_priveleges_subject` (`subject_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_subject` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_subject` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_topic_level1`
--

DROP TABLE IF EXISTS `content_viewer_privileges_topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_topic_level1` (
  `content_viewer_priveleges_topic_level1_cd` varchar(14) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `fk2_content_viewer_priveleges_topic_level1` (`subject_id`,`chapter_id`,`topic_level1_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_topic_level1` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_topic_level1` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_privileges_topic_level2`
--

DROP TABLE IF EXISTS `content_viewer_privileges_topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_privileges_topic_level2` (
  `content_viewer_priveleges_topic_level2_cd` varchar(16) DEFAULT NULL,
  `user_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `read_permission` char(1) DEFAULT NULL,
  `audio_permission` char(1) DEFAULT NULL,
  `video_permission` char(1) DEFAULT NULL,
  `animation_permission` char(1) DEFAULT NULL,
  `program_permission` char(1) DEFAULT NULL,
  `chat_permission` char(1) DEFAULT NULL,
  `forum_permission` char(1) DEFAULT NULL,
  `simulation_permission` char(1) DEFAULT NULL,
  `assignment_permission` char(1) DEFAULT NULL,
  `test_permission` char(1) DEFAULT NULL,
  `marks_review_permission` char(1) DEFAULT NULL,
  `remarks_permission` char(1) DEFAULT NULL,
  `granted_by` int DEFAULT NULL,
  `granted_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`user_id`,`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `fk2_content_viewer_priveleges_topic_level2` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk1_content_viewer_priveleges_topic_level2` FOREIGN KEY (`user_id`) REFERENCES `content_viewer_users` (`user_id`),
  CONSTRAINT `fk2_content_viewer_priveleges_topic_level2` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `content_viewer_users`
--

DROP TABLE IF EXISTS `content_viewer_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_viewer_users` (
  `user_id` int NOT NULL,
  `university_id` int DEFAULT NULL,
  `faculty_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `specialization_id` int DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  `nationality_id` int DEFAULT '1',
  PRIMARY KEY (`user_id`),
  KEY `fk1_content_viewer_users` (`university_id`,`faculty_id`,`department_id`,`course_id`),
  KEY `fk3_content_viewer_users` (`nationality_id`),
  KEY `idx_viewer_user` (`user_id`),
  KEY `idx_viewer_class` (`class_id`),
  CONSTRAINT `fk1_content_viewer_users` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`) REFERENCES `course` (`university_id`, `faculty_id`, `department_id`, `course_id`),
  CONSTRAINT `fk2_content_viewer_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk3_content_viewer_users` FOREIGN KEY (`nationality_id`) REFERENCES `country_list` (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `country_list`
--

DROP TABLE IF EXISTS `country_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `country_list` (
  `country_id` int NOT NULL,
  `country_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `course`
--

DROP TABLE IF EXISTS `course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course` (
  `course_cd` varchar(16) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `course_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `co_ordinator` varchar(50) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`),
  CONSTRAINT `fk_course` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`) REFERENCES `department` (`university_id`, `faculty_id`, `department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department` (
  `department_cd` varchar(13) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `department_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `hod` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `contact_no` varchar(15) DEFAULT NULL,
  `fax_no` varchar(15) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`),
  CONSTRAINT `fk_department` FOREIGN KEY (`university_id`, `faculty_id`) REFERENCES `faculty` (`university_id`, `faculty_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `faculty_cd` varchar(7) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `faculty_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `dean` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `contact_no` varchar(15) DEFAULT NULL,
  `fax_no` varchar(15) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`),
  CONSTRAINT `fk_faculty` FOREIGN KEY (`university_id`) REFERENCES `university` (`university_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image`
--

DROP TABLE IF EXISTS `image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `image` (
  `image_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `image_id` int NOT NULL,
  `image_name` varchar(200) DEFAULT NULL,
  `image_url` varchar(200) DEFAULT NULL,
  `image` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`image_id`),
  KEY `idx_image_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_image` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `learning_content`
--

DROP TABLE IF EXISTS `learning_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_content` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content_type` varchar(32) NOT NULL,
  `resource_url` text NOT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `privileges`
--

DROP TABLE IF EXISTS `privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `privileges` (
  `user_id` int NOT NULL,
  `privilege_level` int NOT NULL,
  `privilege_no` int NOT NULL,
  `university_id` int DEFAULT NULL,
  `faculty_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `specialization_id` int DEFAULT NULL,
  `class_id` int DEFAULT NULL,
  PRIMARY KEY (`user_id`,`privilege_level`,`privilege_no`),
  CONSTRAINT `FKuser_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `program`
--

DROP TABLE IF EXISTS `program`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `program` (
  `program_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `program_id` int NOT NULL,
  `program_name` varchar(200) DEFAULT NULL,
  `program_url` varchar(200) DEFAULT NULL,
  `program` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`program_id`),
  KEY `idx_program_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_program` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_roles_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `simulation`
--

DROP TABLE IF EXISTS `simulation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `simulation` (
  `simulation_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `simulation_id` int NOT NULL,
  `jar_file_name` varchar(200) DEFAULT NULL,
  `class_name` varchar(200) DEFAULT NULL,
  `jsp_file_name` varchar(200) DEFAULT NULL,
  `option_id` int DEFAULT NULL,
  `url` longtext,
  `simulation` mediumblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`simulation_id`),
  KEY `idx_simulation_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_simulation` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `specialization`
--

DROP TABLE IF EXISTS `specialization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `specialization` (
  `specialization_cd` varchar(19) DEFAULT NULL,
  `university_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `department_id` int NOT NULL,
  `course_id` int NOT NULL,
  `specialization_id` int NOT NULL,
  `specialization_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `co_ordinator` varchar(45) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`,`faculty_id`,`department_id`,`course_id`,`specialization_id`),
  CONSTRAINT `fk_specialization` FOREIGN KEY (`university_id`, `faculty_id`, `department_id`, `course_id`) REFERENCES `course` (`university_id`, `faculty_id`, `department_id`, `course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject`
--

DROP TABLE IF EXISTS `subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject` (
  `subject_id` int NOT NULL,
  `subject_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT NULL,
  `subject_code` varchar(50) DEFAULT NULL,
  `description` text,
  `credit_hours` int DEFAULT NULL,
  `semester_no` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_appendix`
--

DROP TABLE IF EXISTS `subject_appendix`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_appendix` (
  `subject_appendix_cd` varchar(10) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `appendix_id` int NOT NULL,
  `content` longtext,
  PRIMARY KEY (`subject_id`,`appendix_id`),
  CONSTRAINT `fk_subject_appendix` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_exercise`
--

DROP TABLE IF EXISTS `subject_exercise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_exercise` (
  `subject_exercise_cd` varchar(10) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `exercise_id` int NOT NULL,
  `content` longtext,
  PRIMARY KEY (`subject_id`,`exercise_id`),
  CONSTRAINT `fk_subject_exercise` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_glossary`
--

DROP TABLE IF EXISTS `subject_glossary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_glossary` (
  `subject_glossary_cd` varchar(12) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int DEFAULT NULL,
  `topic_level2_id` int DEFAULT NULL,
  `topic_level3_id` int DEFAULT NULL,
  `topic_level4_id` int DEFAULT NULL,
  `topic_level5_id` int DEFAULT NULL,
  `keyword_id` int NOT NULL,
  `keyword_name` varchar(200) DEFAULT NULL,
  `Keyword_link` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`keyword_id`),
  CONSTRAINT `fk_subject_glossary` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_index`
--

DROP TABLE IF EXISTS `subject_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_index` (
  `subject_index_cd` varchar(14) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `index_id` int NOT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`index_id`),
  CONSTRAINT `fk_index` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_references`
--

DROP TABLE IF EXISTS `subject_references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_references` (
  `subject_references_cd` varchar(10) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `reference_id` int NOT NULL,
  `reference_name` varchar(200) DEFAULT NULL,
  `reference_location` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`reference_id`),
  CONSTRAINT `fk_subject_references` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subject_solutions`
--

DROP TABLE IF EXISTS `subject_solutions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subject_solutions` (
  `subject_solutions_cd` varchar(15) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `exercise_id` int NOT NULL,
  `solution_id` int NOT NULL,
  `content` longtext,
  PRIMARY KEY (`subject_id`,`exercise_id`,`solution_id`),
  CONSTRAINT `fk_subject_solutions` FOREIGN KEY (`subject_id`, `exercise_id`) REFERENCES `subject_exercise` (`subject_id`, `exercise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level1`
--

DROP TABLE IF EXISTS `topic_level1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level1` (
  `topic_level1_cd` varchar(11) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level1_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `idx_topic1_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`),
  KEY `idx_topic1_cd` (`topic_level1_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level1` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level2`
--

DROP TABLE IF EXISTS `topic_level2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level2` (
  `topic_level2_cd` varchar(14) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level2_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `idx_topic2_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  KEY `idx_topic2_cd` (`topic_level2_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level2` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`) REFERENCES `topic_level1` (`subject_id`, `chapter_id`, `topic_level1_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level3`
--

DROP TABLE IF EXISTS `topic_level3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level3` (
  `topic_level3_cd` varchar(17) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level3_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`),
  KEY `idx_topic3_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`),
  KEY `idx_topic3_cd` (`topic_level3_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level3` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) REFERENCES `topic_level2` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level4`
--

DROP TABLE IF EXISTS `topic_level4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level4` (
  `topic_level4_cd` varchar(20) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level4_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`),
  KEY `idx_topic4_cd` (`topic_level4_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level4` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`) REFERENCES `topic_level3` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `topic_level5`
--

DROP TABLE IF EXISTS `topic_level5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `topic_level5` (
  `topic_level5_cd` varchar(23) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `topic_level5_name` varchar(200) DEFAULT NULL,
  `introduction` longtext,
  `content` longtext,
  `summary` longtext,
  `has_next_level` char(1) DEFAULT NULL,
  `has_image` char(1) DEFAULT NULL,
  `has_simulation` char(1) DEFAULT NULL,
  `has_audio` char(1) DEFAULT NULL,
  `has_video` char(1) DEFAULT NULL,
  `has_animation` char(1) DEFAULT NULL,
  `has_table` char(1) DEFAULT NULL,
  `has_program` char(1) DEFAULT NULL,
  `has_links` char(1) DEFAULT NULL,
  `has_exercise` char(1) DEFAULT NULL,
  `has_solutions` char(1) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `review_status` varchar(50) DEFAULT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `version_no` int DEFAULT NULL,
  `parent_version_id` int DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`),
  KEY `idx_topic5_cd` (`topic_level5_cd`),
  FULLTEXT KEY `content` (`content`,`introduction`,`summary`),
  CONSTRAINT `fk_topic_level5` FOREIGN KEY (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`, `topic_level4_id`) REFERENCES `topic_level4` (`subject_id`, `chapter_id`, `topic_level1_id`, `topic_level2_id`, `topic_level3_id`, `topic_level4_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `university`
--

DROP TABLE IF EXISTS `university`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `university` (
  `university_id` int NOT NULL,
  `aicte_id` varchar(15) DEFAULT NULL,
  `university_name` varchar(200) DEFAULT NULL,
  `has_next_level` char(1) DEFAULT '0',
  `vice_chancellor` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `contact_no` int DEFAULT NULL,
  `fax_no` int DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `responsible_person_name` varchar(100) DEFAULT NULL,
  `responsible_person_role` varchar(100) DEFAULT NULL,
  `responsible_person_address` varchar(255) DEFAULT NULL,
  `responsible_person_contact_no` varchar(20) DEFAULT NULL,
  `responsible_person_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`university_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role_id` int NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `mobile_no` varchar(15) DEFAULT NULL,
  `password_updated_at` timestamp NULL DEFAULT NULL,
  `failed_login_attempts` int DEFAULT '0',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `account_status` varchar(50) DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_users_username` (`username`),
  KEY `fk_users_role` (`role_id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `video`
--

DROP TABLE IF EXISTS `video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `video` (
  `video_cd` varchar(26) DEFAULT NULL,
  `subject_id` int NOT NULL,
  `chapter_id` int NOT NULL,
  `topic_level1_id` int NOT NULL,
  `topic_level2_id` int NOT NULL,
  `topic_level3_id` int NOT NULL,
  `topic_level4_id` int NOT NULL,
  `topic_level5_id` int NOT NULL,
  `video_id` int NOT NULL,
  `video_name` varchar(200) DEFAULT NULL,
  `video_url` varchar(200) DEFAULT NULL,
  `video` longblob,
  `caption` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size_bytes` bigint DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `storage_type` varchar(50) DEFAULT NULL,
  `attached_level` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`,`topic_level3_id`,`topic_level4_id`,`topic_level5_id`,`video_id`),
  KEY `idx_video_hierarchy` (`subject_id`,`chapter_id`,`topic_level1_id`,`topic_level2_id`),
  CONSTRAINT `fk_video` FOREIGN KEY (`subject_id`, `chapter_id`) REFERENCES `chapter` (`subject_id`, `chapter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-14  1:41:43
