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
-- Dumping data for table `admin_content_review_remarks`
--

LOCK TABLES `admin_content_review_remarks` WRITE;
/*!40000 ALTER TABLE `admin_content_review_remarks` DISABLE KEYS */;
INSERT INTO `admin_content_review_remarks` VALUES (1,'chapter','11-8','Not any actual content here just an introductory line about the chapter\'s name itself!',1,'2026-04-11 08:12:55');
/*!40000 ALTER TABLE `admin_content_review_remarks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `admin_privilege_audit`
--

LOCK TABLES `admin_privilege_audit` WRITE;
/*!40000 ALTER TABLE `admin_privilege_audit` DISABLE KEYS */;
INSERT INTO `admin_privilege_audit` VALUES (1,1,3,'viewer_subject',11,NULL,'GRANT','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":false,\"animation_permission\":false,\"remarks_permission\":false,\"has_next_level\":true,\"video_permission\":false,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-27 20:33:18'),(2,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":false,\"animation_permission\":false,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":false,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-27 20:33:18'),(3,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":false,\"animation_permission\":false,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":true,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:10:57'),(4,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":false,\"animation_permission\":false,\"remarks_permission\":false,\"has_next_level\":true,\"video_permission\":true,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:11:04'),(5,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":false,\"animation_permission\":false,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":true,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:11:05'),(6,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":false,\"animation_permission\":false,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":false,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:11:06'),(7,1,2,'developer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"edit_permission\":true,\"review_permission\":false,\"user_id\":2,\"has_next_level\":false,\"write_permission\":true,\"read_permission\":true}','2026-03-29 16:11:23'),(8,1,2,'developer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"edit_permission\":true,\"review_permission\":true,\"user_id\":2,\"has_next_level\":false,\"write_permission\":true,\"read_permission\":true}','2026-03-29 16:11:23'),(9,1,2,'developer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"edit_permission\":true,\"review_permission\":true,\"user_id\":2,\"has_next_level\":true,\"write_permission\":true,\"read_permission\":true}','2026-03-29 16:11:25'),(10,1,2,'developer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"edit_permission\":true,\"review_permission\":true,\"user_id\":2,\"has_next_level\":false,\"write_permission\":true,\"read_permission\":true}','2026-03-29 16:11:28'),(11,1,2,'viewer_subject',11,NULL,'REVOKE','{\"is_active\":0}','2026-03-29 16:11:34'),(12,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":false,\"animation_permission\":true,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":false,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:11:38'),(13,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":true,\"animation_permission\":true,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":false,\"chat_permission\":false,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:11:38'),(14,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":false,\"program_permission\":true,\"animation_permission\":true,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":false,\"chat_permission\":true,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:11:39'),(15,1,3,'viewer_subject',11,NULL,'UPDATE','{\"subject_id\":11,\"forum_permission\":true,\"program_permission\":true,\"animation_permission\":true,\"remarks_permission\":false,\"has_next_level\":false,\"video_permission\":false,\"chat_permission\":true,\"assignment_permission\":false,\"simulation_permission\":false,\"audio_permission\":false,\"marks_review_permission\":false,\"user_id\":3,\"test_permission\":false,\"read_permission\":false}','2026-03-29 16:11:40');
/*!40000 ALTER TABLE `admin_privilege_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `api_routes`
--

LOCK TABLES `api_routes` WRITE;
/*!40000 ALTER TABLE `api_routes` DISABLE KEYS */;
INSERT INTO `api_routes` VALUES (1,'/checkLogin','CheckLoginServlet',1,'2026-03-04 08:36:25'),(2,'/subjects','GetUserProfileAndSubjectsServlet',1,'2026-03-04 08:36:25'),(3,'/GetChaptersServlet','GetChaptersServlet',1,'2026-03-04 08:36:25'),(4,'/ChapterContent','ChapterContent',1,'2026-03-04 08:36:25'),(5,'/LoginServlet','LoginServlet',1,'2026-03-04 08:36:25'),(6,'/Logout','Logout',1,'2026-03-04 08:36:25'),(7,'/AdminDashboard','AdminDashboard',1,'2026-03-04 08:36:25'),(8,'/AudioUploader','AudioUploader',1,'2026-03-04 08:36:25'),(9,'/AudioUploaderAtServer','AudioUploaderAtServer',1,'2026-03-04 08:36:25'),(10,'/ContentDeveloper','ContentDeveloper',1,'2026-03-04 08:36:25'),(11,'/ContentViewer','ContentViewer',1,'2026-03-04 08:36:25'),(12,'/ContentViewerDashboard','ContentViewerDashboard',1,'2026-03-04 08:36:25'),(13,'/Dashboard','Dashboard',1,'2026-03-04 08:36:25'),(14,'/ImageUploader','ImageUploader',1,'2026-03-04 08:36:25'),(15,'/ImageUploaderAtServer','ImageUploaderAtServer',1,'2026-03-04 08:36:25'),(16,'/Manage','Manage',1,'2026-03-04 08:36:25'),(17,'/NavigationPane','NavigationPane',1,'2026-03-04 08:36:25'),(18,'/PlayAudio','PlayAudio',1,'2026-03-04 08:36:25'),(19,'/PlayVideo','PlayVideo',1,'2026-03-04 08:36:25'),(20,'/RunSimulation','RunSimulation',1,'2026-03-04 08:36:25'),(21,'/SessionInfo','SessionInfo',1,'2026-03-04 08:36:25'),(22,'/SimulationUploader','SimulationUploader',1,'2026-03-04 08:36:25'),(23,'/SimulationUploaderAtServer','SimulationUploaderAtServer',1,'2026-03-04 08:36:25'),(24,'/StaticPages','StaticPages',1,'2026-03-04 08:36:25'),(25,'/TestingServlet','TestingServlet',1,'2026-03-04 08:36:25'),(26,'/VideoUploader','VideoUploader',1,'2026-03-04 08:36:25'),(27,'/VideoUploaderAtServer','VideoUploaderAtServer',1,'2026-03-04 08:36:25'),(28,'/ViewImage','ViewImage',1,'2026-03-04 08:36:25'),(29,'/ViewSimulation','ViewSimulation',1,'2026-03-04 08:36:25'),(30,'/LearningContentServlet','LearningContentServlet',1,'2026-03-04 11:46:03'),(31,'/creator/subjects','CreatorSubjectsServlet',1,'2026-03-26 19:10:29'),(32,'/creator/hierarchy','CreatorHierarchyServlet',1,'2026-03-26 19:10:29'),(33,'/creator/save','CreatorSaveContentServlet',1,'2026-03-26 19:10:29'),(34,'/admin/users','AdminModuleServlet',1,'2026-03-27 19:40:13'),(35,'/admin/users/create','AdminModuleServlet',1,'2026-03-27 19:40:13'),(36,'/admin/users/bulk-import','AdminModuleServlet',1,'2026-03-27 19:40:13'),(37,'/admin/users/status','AdminModuleServlet',1,'2026-03-27 19:40:13'),(38,'/admin/users/:user_id','AdminModuleServlet',1,'2026-03-27 19:40:13'),(39,'/admin/users/:user_id/reset-password','AdminModuleServlet',1,'2026-03-27 19:40:13'),(40,'/admin/users/export','AdminModuleServlet',1,'2026-03-27 19:40:13'),(41,'/admin/users/template','AdminModuleServlet',1,'2026-03-27 19:40:13'),(42,'/admin/enrollments','AdminModuleServlet',1,'2026-03-27 19:40:13'),(43,'/admin/enrollments/:enrollment_id/status','AdminModuleServlet',1,'2026-03-27 19:40:13'),(44,'/admin/enrollments/bulk-reassign','AdminModuleServlet',1,'2026-03-27 19:40:13'),(45,'/admin/privileges/viewer/subject','AdminModuleServlet',1,'2026-03-27 19:40:13'),(46,'/admin/privileges/viewer/chapter','AdminModuleServlet',1,'2026-03-27 19:40:13'),(47,'/admin/privileges/viewer/topic-level1','AdminModuleServlet',1,'2026-03-27 19:40:13'),(48,'/admin/privileges/viewer/topic-level2','AdminModuleServlet',1,'2026-03-27 19:40:13'),(49,'/admin/privileges/developer/subject','AdminModuleServlet',1,'2026-03-27 19:40:13'),(50,'/admin/privileges/developer/chapter','AdminModuleServlet',1,'2026-03-27 19:40:13'),(51,'/admin/privileges/overview','AdminModuleServlet',1,'2026-03-27 19:40:13'),(52,'/admin/privileges/export','AdminModuleServlet',1,'2026-03-27 19:40:13'),(53,'/admin/privileges/audit','AdminModuleServlet',1,'2026-03-27 19:40:13'),(54,'/admin/hierarchy/:level','AdminModuleServlet',1,'2026-03-27 19:40:13'),(55,'/admin/hierarchy/:level/:id','AdminModuleServlet',1,'2026-03-27 19:40:13'),(56,'/admin/class-subjects','AdminModuleServlet',1,'2026-03-27 19:40:13'),(57,'/admin/class-subject-chapters','AdminModuleServlet',1,'2026-03-27 19:40:13'),(58,'/admin/dashboard','AdminModuleServlet',1,'2026-03-27 19:40:13'),(59,'/admin/activity','AdminModuleServlet',1,'2026-03-27 19:40:13'),(60,'/admin/api-routes','AdminModuleServlet',1,'2026-03-27 19:40:13'),(61,'/admin/api-routes/:id','AdminModuleServlet',1,'2026-03-27 19:40:13'),(62,'/admin/content/review-queue','AdminModuleServlet',1,'2026-03-27 19:40:13'),(63,'/admin/content/review-queue/:content_type/:composite_id/approve','AdminModuleServlet',1,'2026-03-27 19:40:13'),(64,'/admin/content/review-queue/:content_type/:composite_id/reject','AdminModuleServlet',1,'2026-03-27 19:40:13'),(65,'/admin/content/review-queue/:content_type/:composite_id/move-to-draft','AdminModuleServlet',1,'2026-04-11 19:03:44'),(66,'/admin/privileges/audit/export','AdminModuleServlet',1,'2026-04-12 11:26:39');
/*!40000 ALTER TABLE `api_routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `audio`
--

LOCK TABLES `audio` WRITE;
/*!40000 ALTER TABLE `audio` DISABLE KEYS */;
/*!40000 ALTER TABLE `audio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `chapter`
--

LOCK TABLES `chapter` WRITE;
/*!40000 ALTER TABLE `chapter` DISABLE KEYS */;
INSERT INTO `chapter` VALUES ('0001101',11,1,'Introduction to operating Systems','Operating Systems: It is a software that interfaces between end users and computer hardware.  It manages the resources efficiently and hence it is a resource manager.\nIt can also\n-	Manages processor time\n-	Manages memory\n-	Manages I/O devices\nProcesses can be brought in and put out of poured out of memory.  It is called swapping in and swapping out.\nEach I/O activity should be linked with the active process at any time.  This linking and de-linking is done by operating system.\nThe turn-around time of the processes in a multi-tasking environment should be optimum.\nDesign of operating system should be said that turn-around time minimize.\nThroughput of the system is the number of processes in a unit of time.',NULL,NULL,'1','0','0','0','0','0','0','0','0','0','0',1,NULL,'2026-04-11 07:57:49',NULL,NULL,'Published',1,'2026-04-07 19:09:45','2026-04-07 19:09:45',NULL,NULL,1),('0001102',11,2,'Process Management','Multi-programming is essentially multiplexing of a system resources- such as processor,memory and I/O devices -among a number of active programs. Potential benefits of concurrent execution of programs include increased performance resource utilization and responsiveness of a computer system.process are a primary mechanism for defining and managing concurrent execution of programs under control of a computer system.\nThe concept of a process is either implicitly or explicitly present in all multi-programmed operating system.its significance has also been recognized by the designer of some high-level languages,such as Ada and Modula,that provide mechanism specifically for management of concurrent processes.\nIn essence,a process or task is an instance of a program in execution.It is the smallest unit of work individually schedulable by an operating system.Each multi-programming OS keeps track of all active processes and allocates systemresources to them according to policies device to meet design performance objectives.Just how the operating system knows when to step in,and how to allocate resources in a given situation,is the subject of this chapter.',NULL,NULL,'1','0','0','0','0','0','0','0','0','0','0',2,NULL,'2026-04-11 07:57:49',NULL,NULL,'Published',1,'2026-04-07 19:09:45','2026-04-07 19:09:45',NULL,NULL,1),('0001103',11,3,'Inter-process Synchronization','In this and the subsequent chapter we are primarily concerned with cooperating processes that share some \r\nresources belonging to the entire group or family.\r\n\r\nSuch processes are usually formed and controlled explicitly by programmers to exploit the benefits of concurrency and/or multiprocessing in time-critical applications, \r\nor in complex production-type applications such as CAM(computer aided manufacturing) or a demanding graphical user interface.\n-Inter-process synchronization: A set of protocols and mechanism used to preserve system integrity and consistency when concurrent process share resources that are serially reusable',NULL,NULL,'1','0','0','0','0','0','0','0','0','0','0',3,NULL,'2026-04-11 07:57:49',NULL,NULL,'Published',1,'2026-04-07 19:09:46','2026-04-07 19:09:46',NULL,NULL,1),('0001104',11,4,'Memory Management: Contiguous Allocation','Memory management is primarily concerned with allocation of physical memory of finite capacity to requesting process.No process may be activated before a certain amount of memory can be allocated to it.This chapter presents various approaches to memory management based on contiguous allocation.Contiguous allocation means that each logical object is places in a set of memory locations with strictly consecutive addresses. ',NULL,NULL,'1','0','0','0','0','0','0','0','0','0','0',4,NULL,'2026-04-11 07:57:49',NULL,NULL,'Published',1,'2026-04-07 19:09:46','2026-04-07 19:09:46',NULL,NULL,1),('0001105',11,5,'Memory Management: Non-Contiguous Allocation','Non Contiguous allocation means that memory is allocated in such a way that parts of the single logical object may be placed in non contiguous areas of physical memory. ',NULL,NULL,'1','0','0','0','0','0','0','0','0','0','0',5,NULL,'2026-04-11 19:07:15',NULL,NULL,'Published',1,'2026-04-11 19:07:15','2026-04-11 19:07:15',NULL,NULL,1),('0001106',11,6,'File Management','The file management portion of the operating system is charged with managing data that resides on secondary storage.Logically related data items on the secondary storage are usually organized into named collection called files.\nA file for example may contain a report ,an executable program or a set of commands to the operating system.\nthe common responsibilities of the file management system include the following:\n-mapping of access requests from logical to physical file address space\n-transmission of file elements between main and secondary storage\n-management of a secondary storage,such as keeping track of the status ,allocation and de-allocation of the space\n-support for protection and sharing of files and the recovery and posible restoration of files after system crashes.',NULL,NULL,'1','0','0','0','0','1','0','0','0','0','0',6,NULL,'2026-04-11 07:57:49',NULL,NULL,'Published',1,'2026-04-07 19:09:46','2026-04-07 19:09:46',NULL,NULL,1),('0001107',11,7,'IO Management','The IO management',NULL,NULL,'1','0','0','0','0','1','0','0','0','0','0',7,NULL,'2026-04-11 19:06:19',NULL,NULL,'Published',1,'2026-04-11 19:06:19','2026-04-11 19:06:19',NULL,NULL,1),('0001108',11,8,'Optimization in OS process scheduling','Here we are going to study about optimization techniques in OS process scheduling! Changed content!','',NULL,'0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,8,'2026-04-11 07:57:49','2026-04-12 08:25:48',2,NULL,'Published',1,'2026-04-12 08:25:48','2026-04-12 08:25:48',11,NULL,1);
/*!40000 ALTER TABLE `chapter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `class`
--

LOCK TABLES `class` WRITE;
/*!40000 ALTER TABLE `class` DISABLE KEYS */;
INSERT INTO `class` VALUES ('0000100001001001001001',1,1,1,1,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('010201010101',1,2,1,1,1,1,'MCA-I',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('010201010102',1,2,1,1,1,2,'MCA-II',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('010201010103',1,2,1,1,1,3,'MCA-III',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('001002001002001001',1,2,1,2,1,1,'BE-IV',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001002001',2,1,1,1,2,1,'BE-III',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001002002',2,1,1,1,2,2,'BE-II',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001002003',2,1,1,1,2,3,'BE-I',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001002004',2,1,1,1,2,4,'BE-IV',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `class` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `class_subject`
--

LOCK TABLES `class_subject` WRITE;
/*!40000 ALTER TABLE `class_subject` DISABLE KEYS */;
INSERT INTO `class_subject` VALUES ('000010000100100100100100011',1,1,1,1,1,1,11,NULL,NULL,NULL,NULL,NULL,NULL),('01020101010100008',1,2,1,1,1,1,8,NULL,NULL,NULL,NULL,NULL,NULL),('01020101010100013',1,2,1,1,1,1,13,NULL,NULL,NULL,NULL,NULL,NULL),('01020101010200011',1,2,1,1,1,2,11,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,14,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,2,1,1,1,2,4,5,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,2,1,1,1,2,4,7,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `class_subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `class_subject_chapter`
--

LOCK TABLES `class_subject_chapter` WRITE;
/*!40000 ALTER TABLE `class_subject_chapter` DISABLE KEYS */;
INSERT INTO `class_subject_chapter` VALUES ('0102010101020001101',1,2,1,1,1,2,11,1,NULL,NULL,NULL,NULL,NULL,NULL),('0102010101020001102',1,2,1,1,1,2,11,2,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,1,1,2,11,3,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,1,1,2,11,4,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,1,1,2,11,5,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,1,1,2,11,6,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,1,1,2,11,7,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,1,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,2,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,3,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,4,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,5,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,6,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,7,NULL,NULL,NULL,NULL,NULL,NULL),(NULL,1,2,1,2,1,1,11,8,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `class_subject_chapter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `class_subject_chapter_topic_level1`
--

LOCK TABLES `class_subject_chapter_topic_level1` WRITE;
/*!40000 ALTER TABLE `class_subject_chapter_topic_level1` DISABLE KEYS */;
INSERT INTO `class_subject_chapter_topic_level1` VALUES ('010201010102000110101',1,2,1,1,1,2,11,1,1,NULL,NULL,NULL,NULL,NULL,NULL),('010201010102000110102',1,2,1,1,1,2,11,1,2,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `class_subject_chapter_topic_level1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `class_subject_chapter_topic_level1_topic_level2`
--

LOCK TABLES `class_subject_chapter_topic_level1_topic_level2` WRITE;
/*!40000 ALTER TABLE `class_subject_chapter_topic_level1_topic_level2` DISABLE KEYS */;
INSERT INTO `class_subject_chapter_topic_level1_topic_level2` VALUES ('01020101010200011010201',1,2,1,1,1,2,11,1,2,1,NULL,NULL,NULL,NULL,NULL,NULL),('01020101010200011010202',1,2,1,1,1,2,11,1,2,2,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `class_subject_chapter_topic_level1_topic_level2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_developer_privileges_chapter`
--

LOCK TABLES `content_developer_privileges_chapter` WRITE;
/*!40000 ALTER TABLE `content_developer_privileges_chapter` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_developer_privileges_chapter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_developer_privileges_subject`
--

LOCK TABLES `content_developer_privileges_subject` WRITE;
/*!40000 ALTER TABLE `content_developer_privileges_subject` DISABLE KEYS */;
INSERT INTO `content_developer_privileges_subject` VALUES ('0000100011',2,11,'0','1','1','1','1',1,'2026-03-29 10:41:28',NULL,1,NULL);
/*!40000 ALTER TABLE `content_developer_privileges_subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_developer_privileges_topic_level1`
--

LOCK TABLES `content_developer_privileges_topic_level1` WRITE;
/*!40000 ALTER TABLE `content_developer_privileges_topic_level1` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_developer_privileges_topic_level1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_developer_privileges_topic_level2`
--

LOCK TABLES `content_developer_privileges_topic_level2` WRITE;
/*!40000 ALTER TABLE `content_developer_privileges_topic_level2` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_developer_privileges_topic_level2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_developer_users`
--

LOCK TABLES `content_developer_users` WRITE;
/*!40000 ALTER TABLE `content_developer_users` DISABLE KEYS */;
INSERT INTO `content_developer_users` VALUES (2,1,1,1,1,1),(4,1,2,1,2,1);
/*!40000 ALTER TABLE `content_developer_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_viewer_class_enrollment`
--

LOCK TABLES `content_viewer_class_enrollment` WRITE;
/*!40000 ALTER TABLE `content_viewer_class_enrollment` DISABLE KEYS */;
INSERT INTO `content_viewer_class_enrollment` VALUES (1,5,1,2,1,2,1,1,'HOME','ACTIVE',NULL,NULL,1,'2026-04-12 18:10:51'),(2,5,2,1,1,1,2,2,'EXPLICIT','ACTIVE',NULL,NULL,1,'2026-04-12 18:13:40');
/*!40000 ALTER TABLE `content_viewer_class_enrollment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_viewer_privileges_chapter`
--

LOCK TABLES `content_viewer_privileges_chapter` WRITE;
/*!40000 ALTER TABLE `content_viewer_privileges_chapter` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_viewer_privileges_chapter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_viewer_privileges_subject`
--

LOCK TABLES `content_viewer_privileges_subject` WRITE;
/*!40000 ALTER TABLE `content_viewer_privileges_subject` DISABLE KEYS */;
INSERT INTO `content_viewer_privileges_subject` VALUES (NULL,3,11,'0','0','0','0','1','1','1','1','0','0','0','0','0',1,'2026-03-29 10:41:41',NULL,1,NULL),('0000100001',103,1,'0','1','1','1','1','1','1','1','1','1','1','1','1',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `content_viewer_privileges_subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_viewer_privileges_topic_level1`
--

LOCK TABLES `content_viewer_privileges_topic_level1` WRITE;
/*!40000 ALTER TABLE `content_viewer_privileges_topic_level1` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_viewer_privileges_topic_level1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_viewer_privileges_topic_level2`
--

LOCK TABLES `content_viewer_privileges_topic_level2` WRITE;
/*!40000 ALTER TABLE `content_viewer_privileges_topic_level2` DISABLE KEYS */;
/*!40000 ALTER TABLE `content_viewer_privileges_topic_level2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `content_viewer_users`
--

LOCK TABLES `content_viewer_users` WRITE;
/*!40000 ALTER TABLE `content_viewer_users` DISABLE KEYS */;
INSERT INTO `content_viewer_users` VALUES (3,1,2,1,1,1,2,1),(5,1,2,1,2,1,1,1);
/*!40000 ALTER TABLE `content_viewer_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `country_list`
--

LOCK TABLES `country_list` WRITE;
/*!40000 ALTER TABLE `country_list` DISABLE KEYS */;
INSERT INTO `country_list` VALUES (1,'India');
/*!40000 ALTER TABLE `country_list` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `course`
--

LOCK TABLES `course` WRITE;
/*!40000 ALTER TABLE `course` DISABLE KEYS */;
INSERT INTO `course` VALUES ('01010101',1,1,1,1,'BSc','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('01020101',1,2,1,1,'MCA','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('01020102',1,2,1,2,'BE','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('01020201',1,2,2,1,'BE','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('01020202',1,2,2,2,'ME','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001',2,1,1,1,'Bachelor of Engineering','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001002',2,1,1,2,'Master of Computer Applications','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `department`
--

LOCK TABLES `department` WRITE;
/*!40000 ALTER TABLE `department` DISABLE KEYS */;
INSERT INTO `department` VALUES ('010101',1,1,1,'Mathematics','1','','','','','',NULL,NULL,NULL,NULL,NULL),('010102',1,1,2,'STATISTICS','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('010201',1,2,1,'COMPUTER SCIENCE','1','','','','','',NULL,NULL,NULL,NULL,NULL),('010202',1,2,2,'MECHANICAL','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('010203',1,2,3,'ELECTRICAL','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('010204',1,2,4,'ELECTRONICS','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001',2,1,1,'CSE','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `department` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES ('0101',1,1,'FACULTY OF SCIENCE','1','','','','','',NULL,NULL,NULL,NULL,NULL),('0102',1,2,'FACULTY OF TECHNOLOGY','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0103',1,3,'FACULTY OF ARTS','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0104',1,4,'FACULTY OF COMMERCE','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001',2,1,'Faculty of Science','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `image`
--

LOCK TABLES `image` WRITE;
/*!40000 ALTER TABLE `image` DISABLE KEYS */;
/*!40000 ALTER TABLE `image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `learning_content`
--

LOCK TABLES `learning_content` WRITE;
/*!40000 ALTER TABLE `learning_content` DISABLE KEYS */;
INSERT INTO `learning_content` VALUES (1,'Computer Architecture','IMAGE','/computer-architecture.png',NULL,'2026-03-04 11:37:11'),(2,'Prime Number Program','PROGRAM','/prime-check.py',NULL,'2026-03-04 11:37:11'),(3,'OS Video Demo','VIDEO','https://www.youtube.com/watch?v=Dxcc6ycZ73M',NULL,'2026-03-04 11:37:11'),(4,'Sorting Simulation','SIMULATION','https://visualgo.net/en/sorting',NULL,'2026-03-04 11:37:11'),(5,'Audio Sample','AUDIO','https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',NULL,'2026-03-04 11:37:11');
/*!40000 ALTER TABLE `learning_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `privileges`
--

LOCK TABLES `privileges` WRITE;
/*!40000 ALTER TABLE `privileges` DISABLE KEYS */;
INSERT INTO `privileges` VALUES (101,1,2,1,3,0,0,0,0),(102,2,1,1,2,2,0,0,0);
/*!40000 ALTER TABLE `privileges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `program`
--

LOCK TABLES `program` WRITE;
/*!40000 ALTER TABLE `program` DISABLE KEYS */;
/*!40000 ALTER TABLE `program` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN','System Administrator'),(2,'CONTENT_DEVELOPER','Content Creator'),(3,'CONTENT_VIEWER','Student/User');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `simulation`
--

LOCK TABLES `simulation` WRITE;
/*!40000 ALTER TABLE `simulation` DISABLE KEYS */;
INSERT INTO `simulation` VALUES ('0001102000000000011',11,2,0,0,0,0,0,11,'AllSimulationJar.jar','ProcessWithPriorityMain','AllSimulationJnlp.jsp',2,'/wls/lib/AllSimulationJnlp.jsp?option=2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001102000000000012',11,2,0,0,0,0,0,12,'AllSimulationJar.jar','ProcessSchedulingBothMain','AllSimulationJnlp.jsp',3,'/wls/lib/AllSimulationJnlp.jsp?option=3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001102060000000001',11,2,6,0,0,0,0,1,'AllSimulationJar.jar','ProcessWithoutPriorityMain','AllSimulationJnlp.jsp',1,'/wls/lib/AllSimulationJnlp.jsp?option=1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001103000000000013',11,3,0,0,0,0,0,13,'AllSimulationJar.jar','SMutexMain','AllSimulationJnlp.jsp',4,'/wls/lib/AllSimulationJnlp.jsp?option=4',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001103000000000014',11,3,0,0,0,0,0,14,'AllSimulationJar.jar','DiningPhilosopherMain','AllSimulationJnlp.jsp',7,'/wls/lib/AllSimulationJnlp.jsp?option=7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001103060100000002',11,3,6,1,0,0,0,2,'AllSimulationJar.jar','ProducerConsumerMain','AllSimulationJnlp.jsp',6,'/wls/lib/AllSimulationJnlp.jsp?option=6',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001103060200000003',11,3,6,2,0,0,0,3,'AllSimulationJar.jar','ReaderWriterMain','AllSimulationJnlp.jsp',5,'/wls/lib/AllSimulationJnlp.jsp?option=5',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001104020100000004',11,4,2,1,0,0,0,4,'AllSimulationJar.jar','MemoryMain','AllSimulationJnlp.jsp',8,'/wls/lib/AllSimulationJnlp.jsp?option=8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001105020100000006',11,5,2,1,0,0,0,6,'AllSimulationJar.jar','VirtualMemoryMain','AllSimulationJnlp.jsp',11,'/wls/lib/AllSimulationJnlp.jsp?option=11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001105020500000007',11,5,2,5,0,0,0,7,'AllSimulationJar.jar','PageReplacementMain','AllSimulationJnlp.jsp',10,'/wls/lib/AllSimulationJnlp.jsp?option=10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001105021000000008',11,5,2,10,0,0,0,8,'AllSimulationJar.jar','VirtualMemoryWithSegmentationMain','AllSimulationJnlp.jsp',12,'/wls/lib/AllSimulationJnlp.jsp?option=12',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001105030100000005',11,5,3,1,0,0,0,5,'AllSimulationJar.jar','MemoryWithFreePoolMain','AllSimulationJnlp.jsp',9,'/wls/lib/AllSimulationJnlp.jsp?option=9',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001106000000000009',11,6,0,0,0,0,0,9,'AllSimulationJar.jar','FileMain','AllSimulationJnlp.jsp',13,'/wls/lib/AllSimulationJnlp.jsp?option=13',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0001106000000000010',11,6,0,0,0,0,0,10,'AllSimulationJar.jar','IOMain','AllSimulationJnlp.jsp',14,'/wls/lib/AllSimulationJnlp.jsp?option=14',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `simulation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `specialization`
--

LOCK TABLES `specialization` WRITE;
/*!40000 ALTER TABLE `specialization` DISABLE KEYS */;
INSERT INTO `specialization` VALUES ('0000100001001001001',1,1,1,1,1,'Computer Science & Engineering with DATA SCIENCE','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0102010101',1,2,1,1,1,'Computer Applications','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0102010102',1,2,1,1,2,'Computer Science','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('001002001002001',1,2,1,2,1,'Computer Science','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0102020201',1,2,2,2,1,'ME-Mechanical-Production','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('0102020202',1,2,2,2,2,'ME-Mechanical-Automobiles','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001001',2,1,1,1,1,'Computer Science','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001002',2,1,1,1,2,'Data Science','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('002001001001003',2,1,1,1,3,'Quantum Computing','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `specialization` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subject`
--

LOCK TABLES `subject` WRITE;
/*!40000 ALTER TABLE `subject` DISABLE KEYS */;
INSERT INTO `subject` VALUES (1,'GEOMETRY',NULL,NULL,NULL,NULL,NULL,NULL),(2,'TRIGNOMETRY',NULL,NULL,NULL,NULL,NULL,NULL),(3,'CALCULUS',NULL,NULL,NULL,NULL,NULL,NULL),(4,'LPP',NULL,NULL,NULL,NULL,NULL,NULL),(5,'PROBABILITY',NULL,NULL,NULL,NULL,NULL,NULL),(6,'DISTRIBUTIONS',NULL,NULL,NULL,NULL,NULL,NULL),(7,'REGRESSION',NULL,NULL,NULL,NULL,NULL,NULL),(8,'SP&NM',NULL,NULL,NULL,NULL,NULL,NULL),(9,'CO',NULL,NULL,NULL,NULL,NULL,NULL),(10,'IT',NULL,NULL,NULL,NULL,NULL,NULL),(11,'OPERATING SYSTEM',NULL,NULL,NULL,NULL,NULL,NULL),(12,'RDBMS',NULL,NULL,NULL,NULL,NULL,NULL),(13,'CPP',NULL,NULL,NULL,NULL,NULL,NULL),(14,'JAVA',NULL,NULL,NULL,NULL,NULL,NULL),(15,'.net',NULL,NULL,NULL,NULL,NULL,NULL),(16,'WT',NULL,NULL,NULL,NULL,NULL,NULL),(17,'MECH',NULL,NULL,NULL,NULL,NULL,NULL),(18,'ROBOTICS',NULL,NULL,NULL,NULL,NULL,NULL),(19,'DYNAMIC',NULL,NULL,NULL,NULL,NULL,NULL),(20,'KINEMATICS',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `subject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subject_appendix`
--

LOCK TABLES `subject_appendix` WRITE;
/*!40000 ALTER TABLE `subject_appendix` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_appendix` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subject_exercise`
--

LOCK TABLES `subject_exercise` WRITE;
/*!40000 ALTER TABLE `subject_exercise` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_exercise` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subject_glossary`
--

LOCK TABLES `subject_glossary` WRITE;
/*!40000 ALTER TABLE `subject_glossary` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_glossary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subject_index`
--

LOCK TABLES `subject_index` WRITE;
/*!40000 ALTER TABLE `subject_index` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subject_references`
--

LOCK TABLES `subject_references` WRITE;
/*!40000 ALTER TABLE `subject_references` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_references` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `subject_solutions`
--

LOCK TABLES `subject_solutions` WRITE;
/*!40000 ALTER TABLE `subject_solutions` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_solutions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `topic_level1`
--

LOCK TABLES `topic_level1` WRITE;
/*!40000 ALTER TABLE `topic_level1` DISABLE KEYS */;
INSERT INTO `topic_level1` VALUES ('000110101',11,1,1,'Evolution of Operating Systems','','\n  \n    \n  \n  \n    As the name suggests it is a single layered. All earlier versions of \n    operating system was of this type. - <b>Resource management</b> or \n    allocation for the program and maintenance of the code is difficult. - \n    They were written typically and customized for a specific machine only. - \n    They were specific to the hardware. - The specifications were hard-bounded \n    so they were less or not at all portable.\n  \n\n','','0','0','0','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:47','2026-04-07 19:09:47',1,NULL,1),('000110102',11,1,2,' Types of Operating  Systems','','\n  \n    \n  \n  \n    <p style=\"margin-top: 0\">\n      <font color=\"#000000\" size=\"4\">\n</font>    </p>\n    <p style=\"margin-top: 0\">\n      <font size=\"4\" color=\"#000000\">1. Batch operating system \n</font>    </p>\n    <p style=\"margin-top: 0\">\n      <font color=\"#000000\" size=\"4\">2. multi-programming operating system\n</font>    </p>\n    <p style=\"margin-top: 0\">\n      <font size=\"4\" color=\"#000000\">3. Real time operating system\n</font>    </p>\n    <p style=\"margin-top: 0\">\n      <font color=\"#000000\" size=\"4\">4. Time sharing system\n</font>    </p>\n    <p style=\"margin-top: 0\">\n      <font color=\"#000000\" size=\"4\">5. Distributed operating system</font>\n    </p>\n  \n\n','','1','0','0','0','0','0','0','0','0','0','0',2,NULL,'2026-04-07 18:12:36',NULL,NULL,'Published',1,'2026-04-07 19:09:45','2026-04-07 19:09:45',4,NULL,1),('000110206',11,2,6,'Scheduling algorithms',NULL,'The scheduling mechanism described in this section may, at least in theory,be used by any of three type of schedulers.As pointed out earlier some algorithm are better suited suited to the need of a particular type of scheduler.Depending on the whether a particular scheduling discipline is primarily used by the long-term or by the short-term scheduler,we illustrate its working by using the term job or process for a unit of work,respectively.',NULL,'1','0','1','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:44','2026-04-07 19:09:44',1,NULL,1),('000110301',11,3,1,'Need for inter-process synchronization',NULL,'The use of shared variables is a simple and common form of communication among cooperating processes.\r\nWhen a set of processes have access to a common address space, they can use shared variables for a number of purposes, such as \r\nflags and accumulating collective results.',NULL,'1','0','0','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:44','2026-04-07 19:09:44',1,NULL,1),('000110302',11,3,2,'Mutual Exclusion',NULL,'When a process enters a critical section, it must complete all instructions therein before any other process is allowed to \r\nenter the same critical section. Only the process executing the critical section is allowed access to the shared variables; all other processes should be prevented \r\nfrom doing so until the completion of the critical section. this is called MUTUAL EXCLUSION.',NULL,'1','0','0','0','0','0','0','0','0','0','0',2,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:43','2026-04-07 19:09:43',1,NULL,1),('000110306',11,3,6,'Classical problems in concurrent programming',NULL,'In this section we explore several problems that have a prominent place in theory and practice of concurrent programming.\nAfter analyzing each problem,we present one or more solutions based on semaphores.\nThese problems are also solved using the alternative synchronization methods.By keeping the overall structure of solution based on different mechanisms as similar as possible,our intention is to use the presented problems as a common reference for comparisons.',NULL,'1','0','0','1','0','0','0','0','0','0','0',3,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:43','2026-04-07 19:09:43',1,NULL,1),('000110402',11,4,2,'Partitioned memory allocation-static','','\n  \n    \n  \n  \n    One way to support multi-programming is to divide the available physical \n    memory into several partitions,each of which may be allocated to a \n    different process\nthere are two types of partitioning system:-\n1. Static partitioning\n2. Dynamic partitioning\n  \n\n','','1','0','0','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:40','2026-04-07 19:09:40',1,NULL,1),('000110403',11,4,3,'Partitioned memory allocation-Dynamic',NULL,'Apparently,internal fragmentation and other problems attributable to static partitioning of memory should be alleviated by defining partitions dynamically,in accordance with the requirements of each particular set of active processes. Starting with the initial set of the system,partitions may be created dynamically to fit the needs of each requesting process.when a process terminates or becomes swapped out,the memory manager can return the vacated space to the pool of free memory areas from which partitions allocations are made.',NULL,'1','0','0','0','0','0','0','0','0','0','0',2,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:42','2026-04-07 19:09:42',1,NULL,1),('000110502',11,5,2,'Virtual Memory',NULL,'Virtual memory is a memory management scheme where only a portion of the virtual address space of a resident process may actually be loaded into a physical memory..',NULL,'1','0','0','0','0','0','0','0','0','0','0',1,NULL,'2026-04-07 18:53:29',NULL,NULL,'Published',1,'2026-04-07 19:09:43','2026-04-07 19:09:43',2,NULL,1);
/*!40000 ALTER TABLE `topic_level1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `topic_level2`
--

LOCK TABLES `topic_level2` WRITE;
/*!40000 ALTER TABLE `topic_level2` DISABLE KEYS */;
INSERT INTO `topic_level2` VALUES ('00011010201',11,1,2,1,' Batch Operating  Systems',NULL,'It follows batch processing i.e. serial processing.\nIf there are more than one process submitted to the operating system,  still they will be executed serially i.e. one after the other.\nIf there are two processes P1 and P2,\nImg 6\nDuring I/O activity the CPU remain idle in spite of many processes in queue which is wastage of the CPU time.\nFor a very short duration, the operating system code is in the execution for switch over i.e. for loading and unloading of the process states of the CPU. This is called process switching i.e. bringing out of a process from CPU and bringing in a new process into CPU.\nProcess to OS or OS to process is context switching.\nProcess to OS to process is completely called process switching.\nBatch OS uses first-come-first-serve basic as the type of scheduling involved. Here process management is minimal i.e. hardly any process management is required.\nHere Process Management implies  Time Management and Memory Management implies  Space Management\nThe turn-around time of the process in batch operating system will depend on the type of the queue. According to the fig. If the process P2 arrived at 1st time unit, its turn-around time is n+m.\nThe average turn-around time of the system will be dependent on the formation of the queue.\nThe throughput of the system i.e. the number of processes executed in unit time defined by the operating system is dependent on the formation of the queue.\nBatch OS is designed in such a way that it does not have to take any decision in case of process management.\nBecause there is only one task in execution at any point of time, only that process should be loaded in RAM. So memory management is also serialized and hence it is minimal.\nWe have only one process in RAM at a time so the issue of sharing memory and protection also does not come into picture.\nIn case of sharing, concurrency control is also involved to preserve the state of the resource i.e. if one process is accessing the shared resource, the OS should not allow any other process to access it.\nIn case of protection, if a contiguous memory is allocated to a particular process, than any other process should not be able to refer to any part of that address space. The fence register contains the starting and ending addresses of all processes.\nFence register = Base register + Limit register.\nFile management also become minimal. There may be many files residing on the secondary storage. But before execution only one file is loaded into RAM as needed by the process in execution in batch OS.\nOptimal usage of the resources is not done in batch OS.\nI/O management is also very simple as there is only process executing which may need I/O resources.\nThus resource management in batch OS is very primitive i.e. simple.',NULL,'1','0','0','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:44','2026-04-07 19:09:44',1,NULL,1),('00011010202',11,1,2,2,' Multi Programming Operating  Systems',NULL,'The term multi-programming  denotes an operating system that,in addition to supporting multitasking,provides sophisticated form of memory protection and enforces concurrency control when processes access shared I/O device and files.',NULL,'1','0','0','0','0','0','0','0','0','0','0',2,NULL,'2026-04-07 18:40:49',NULL,NULL,'Published',1,'2026-04-07 19:09:44','2026-04-07 19:09:44',10,NULL,1),('00011030601',11,3,6,1,'The producer/Consumer problem',NULL,'In general the producer/consumer problem may be stated as follows.\n-Given a set of cooperating processes, some of  which produce data items(producers) to be consumed by others(consumers),with possible disparity between production and consumption rates,\n-Devise a synchronization protocol that allows both producers and consumers to operate concurrently at their respective service rates in such a way that produced items are consumed in the exact order in which they are produced(FIFO).',NULL,'0','0','1','1','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:44','2026-04-07 19:09:44',1,NULL,1),('00011030602',11,3,6,2,'Readers and Writers',NULL,'Readers and writers are another classical problem in concurrent programming with numerous applications in practice.\nIt basically resolves around a number of processes using a shared global data-structure.\nThe processes are categorized depending on their usage of the resource,as either reader or writer.\nA reader never modifies the shared data-structure, whereas writer may both read it and write into it.\na number of users may use the shared data-structure concurrently  because no matter how they are interleaved,they cannot possibly compromise the consistency.\nWriters,on the other hand,must be granted exclusive access to data.',NULL,'1','0','1','0','0','0','0','0','0','0','0',2,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:48','2026-04-07 19:09:48',1,NULL,1),('00011040201',11,4,2,1,'Principles of operation',NULL,'Once partitions are defined, an operating system needs to keep track of their status,such as free or in use,for allocation purpose.current partition status and attributes are often collected in a data structure called the partition description table.',NULL,'1','0','1','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:49','2026-04-07 19:09:49',1,NULL,1),('00011040301',11,4,3,1,'Principles of operation',NULL,'When a resident process terminates or becomes swapped out,the operating system terminates the related partition. This basically consists of returning the partitions space to the pool of free memory and the invalidating the corresponding PDT entry.For swapped out processes,the operating system also invalidate the PCB field where the identity of the allocated partitions is normally held.',NULL,'1','0','1','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:49','2026-04-07 19:09:49',1,NULL,1),('00011050201',11,5,2,1,'Principles of operation',NULL,'Virtual memory can be implemented as an extention of paged or segmented memory management or as combination of both.Accordingly address translation is performed by means of PMT,SDT ,or both.',NULL,'1','0','1','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:49','2026-04-07 19:09:49',1,NULL,1),('00011050205',11,5,2,5,'Replacement Policies',NULL,'A replacement policies governs the choice of the victim page when eviction is in order,depending on whether they have been modified or not ,items to be removed may have to be written back to the disk or simply discarded.',NULL,'1','0','1','0','0','0','0','0','0','0','0',2,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:09:50','2026-04-07 19:09:50',1,NULL,1),('00011050210',11,5,2,10,'segmentation and paging',NULL,'It is also possible to implement virtual memory in the form of demand segmentation,such implementations usually inherits the benefits of sharing and protection provided by segmentation',NULL,'1','0','1','0','0','0','0','0','0','0','0',3,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:10:14','2026-04-07 19:10:14',1,NULL,1);
/*!40000 ALTER TABLE `topic_level2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `topic_level3`
--

LOCK TABLES `topic_level3` WRITE;
/*!40000 ALTER TABLE `topic_level3` DISABLE KEYS */;
INSERT INTO `topic_level3` VALUES ('0001101020201',11,1,2,2,1,'Time Sharing Systems',NULL,'There will be many processes in execution at any given point of time.\nHere we are mainly considering the uni-processing environment.\nIt includes Multi-tasking, Multi-user,  Multi-access.\n',NULL,'1','0','0','0','0','0','0','0','0','0','0',1,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:10:14','2026-04-07 19:10:14',1,NULL,1),('0001101020202',11,1,2,2,2,'Real Time Systems',NULL,'The time delay in processing should tend to zero i.e. the response should be as fast as possible.\nMainly implemented in multiprocessing environment.\nProcess management should be very efficient with minimum switch overs.\nUsually all process should reside in the primary memory only so that no time is wasted in loading the processes from secondary storage or registers.\nThus hardly any memory management is required.\nInterrupt management should be very efficient in case of real time OS.\nMessages will be coming in the form of events.\nI/O management i.e. device management should be very efficient in case of real time OS.\nInterprocess communication should also be very efficient.\nEverything resides in RAM so there is no file management in real time OS.',NULL,'1','0','0','0','0','0','0','0','0','0','0',2,NULL,NULL,NULL,NULL,'Published',1,'2026-04-07 19:10:13','2026-04-07 19:10:13',1,NULL,1);
/*!40000 ALTER TABLE `topic_level3` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `topic_level4`
--

LOCK TABLES `topic_level4` WRITE;
/*!40000 ALTER TABLE `topic_level4` DISABLE KEYS */;
/*!40000 ALTER TABLE `topic_level4` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `topic_level5`
--

LOCK TABLES `topic_level5` WRITE;
/*!40000 ALTER TABLE `topic_level5` DISABLE KEYS */;
/*!40000 ALTER TABLE `topic_level5` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `university`
--

LOCK TABLES `university` WRITE;
/*!40000 ALTER TABLE `university` DISABLE KEYS */;
INSERT INTO `university` VALUES (1,'1-34567852459','MSU','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'1-34567857359','SP','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'1-34857852459','Gujarat Uni','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,'1-34926852459','DDIT','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(5,'1-34563852459','NIRMA','0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `university` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','yfDt/VB75e6ykjR3gqCVvmGwcDqu7l8Sf1w7nw0Gftv76sH77ec85Vdjxg5G+NXhs0KyocouKlo+whhv0TqVlw==',1,'System','Admin','admin@wls.com','9999999999','2026-04-08 19:03:52',0,'2026-04-13 16:47:44','ACTIVE','2026-03-26 19:10:26','2026-04-13 16:47:44'),(2,'democreator','qu4XQQBNRa78FPp3l66GU7fvIXkR+96IoYvtCj7rtRpa8SrBUVFBt+YldOoORIQ9UpckwioLH/qVVYVwNZrsNw==',2,'Content','Creator','creator@wls.com','8888888888','2026-04-08 19:03:05',0,'2026-04-12 16:00:14','ACTIVE','2026-03-26 19:10:26','2026-04-12 16:00:14'),(3,'demoviewer','Ze6EjawPXcYa3dkU6hQsiiczsh1PQh2LV7AeSiAaKYJkF/iVfafrjuONgwufGDr94XTFnXqdU1x02APzr1o54A==',3,'Student','User','student@wls.com',NULL,'2026-04-10 17:12:33',0,'2026-04-12 15:59:56','ACTIVE','2026-03-26 19:10:26','2026-04-12 15:59:56'),(4,'Creator 1','kQIfb856/6vuJrB+RIdbLXOgCho375w+/T+jGryRJxCAME4cS+tMnKQmCsjrO9vHi01MNJQ1LXVMxxLOeiBBBg==',2,'Creator_1','1_Creator','creator1@gmail.com','9999888822',NULL,0,NULL,'ACTIVE','2026-04-08 17:58:31','2026-04-08 17:58:31'),(5,'Student_1','6u0zMeDwoHA5PGXJF8rmeU9nK6/OWGhakaK6N7VhxCvzrzAuP4QMbiUWw6UV6XXDCshCwlGeXcdaf2htARoGbA==',3,'Student_1','1_Student','student1@gmail.com','9999888800','2026-04-12 07:48:30',0,'2026-04-12 08:31:03','ACTIVE','2026-04-12 07:48:30','2026-04-12 08:31:03');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `video`
--

LOCK TABLES `video` WRITE;
/*!40000 ALTER TABLE `video` DISABLE KEYS */;
/*!40000 ALTER TABLE `video` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-14  1:42:24
