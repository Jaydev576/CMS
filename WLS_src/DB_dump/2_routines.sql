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
-- Dumping routines for database 'wls'
--
/*!50003 DROP PROCEDURE IF EXISTS `add_learning_content` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_learning_content`(
    IN p_title VARCHAR(255),
    IN p_content_type VARCHAR(32),
    IN p_resource_url TEXT,
    IN p_created_by INT
)
BEGIN
    INSERT INTO learning_content (title, content_type, resource_url, created_by)
    VALUES (p_title, p_content_type, p_resource_url, p_created_by);

    SELECT LAST_INSERT_ID() AS inserted_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cascade_code_topic_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `cascade_code_topic_2`(in sub_id int(5))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id FROM topic_level2
							WHERE subject_id=sub_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level2 set topic_level2_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2;
	END LOOP;
    CLOSE cur1;
    call cascade_code_topic_3(sub_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cascade_code_topic_3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `cascade_code_topic_3`(in sub_id int(5))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2,t3 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id FROM topic_level3
							WHERE subject_id=sub_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2,t3;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level3 set topic_level3_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0),lpad(t3,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2 
            AND topic_level3_id = t3;
	END LOOP;
    CLOSE cur1;
    call cascade_code_topic_4(sub_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cascade_code_topic_4` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `cascade_code_topic_4`(in sub_id int(5))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2,t3,t4 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id,topic_level4_id FROM topic_level4
							WHERE subject_id=sub_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2,t3,t4;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level4 set topic_level4_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0),lpad(t3,2,0),lpad(t4,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2 
            AND topic_level3_id = t3
			AND topic_level4_id = t4;
	END LOOP;
    CLOSE cur1;
    call cascade_code_topic_5(sub_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cascade_code_topic_5` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `cascade_code_topic_5`(in sub_id int(5))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2,t3,t4,t5 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id,topic_level4_id,topic_level5_id FROM topic_level5
							WHERE subject_id=sub_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2,t3,t4,t5;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level5 set topic_level5_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0),lpad(t3,2,0),lpad(t4,2,0),lpad(t5,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2 
            AND topic_level3_id = t3
            AND topic_level4_id = t4
            AND topic_level5_id = t5;
	END LOOP;
    
    CLOSE cur1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_subject_access_for_viewer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `check_subject_access_for_viewer`(
    IN p_user_id INT,
    IN p_subject_id INT
)
BEGIN
    SELECT 1 AS has_access
    FROM (
        SELECT cs.subject_id
        FROM content_viewer_users cvu
        JOIN class_subject cs
          ON cs.university_id = cvu.university_id
         AND cs.faculty_id = cvu.faculty_id
         AND cs.department_id = cvu.department_id
         AND cs.course_id = cvu.course_id
         AND cs.specialization_id = cvu.specialization_id
         AND cs.class_id = cvu.class_id
        WHERE cvu.user_id = p_user_id

        UNION

        SELECT cs.subject_id
        FROM content_viewer_class_enrollment cvce
        JOIN class_subject cs
          ON cs.university_id = cvce.university_id
         AND cs.faculty_id = cvce.faculty_id
         AND cs.department_id = cvce.department_id
         AND cs.course_id = cvce.course_id
         AND cs.specialization_id = cvce.specialization_id
         AND cs.class_id = cvce.class_id
        WHERE cvce.user_id = p_user_id
          AND cvce.status = 'ACTIVE'
          AND (cvce.valid_from IS NULL OR cvce.valid_from <= CURRENT_TIMESTAMP)
          AND (cvce.valid_to IS NULL OR cvce.valid_to >= CURRENT_TIMESTAMP)
    ) accessible_subjects
    WHERE accessible_subjects.subject_id = p_subject_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `count_direct_children_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `count_direct_children_creator`(
    IN p_level INT,
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT
)
BEGIN
    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;

    SET @tableName = CONCAT('topic_level', p_level);
    SET @query = CONCAT('SELECT COUNT(*) AS child_count FROM ', @tableName, ' WHERE subject_id = ? AND chapter_id = ?');
    
    IF p_p1 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level1_id = ?'); END IF;
    IF p_p2 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level2_id = ?'); END IF;
    IF p_p3 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level3_id = ?'); END IF;
    IF p_p4 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level4_id = ?'); END IF;
    
    PREPARE stmt FROM @query;
    
    IF p_p4 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
    ELSEIF p_p3 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
    ELSEIF p_p2 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
    ELSEIF p_p1 > 0 THEN EXECUTE stmt USING @s, @c, @t1;
    ELSE EXECUTE stmt USING @s, @c;
    END IF;
    
    DEALLOCATE PREPARE stmt;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_scoped_rows_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_scoped_rows_creator`(
    IN p_table_name VARCHAR(64),
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT,
    IN p_p5 INT
)
BEGIN
    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;
    SET @t5 = p_p5;

    SET @query = CONCAT('DELETE FROM `', p_table_name, '` WHERE subject_id = ? AND chapter_id = ?');
    
    IF p_p1 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level1_id = ?'); END IF;
    IF p_p2 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level2_id = ?'); END IF;
    IF p_p3 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level3_id = ?'); END IF;
    IF p_p4 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level4_id = ?'); END IF;
    IF p_p5 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level5_id = ?'); END IF;
    
    PREPARE stmt FROM @query;
    
    IF p_p5 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4, @t5;
    ELSEIF p_p4 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
    ELSEIF p_p3 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
    ELSEIF p_p2 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
    ELSEIF p_p1 > 0 THEN EXECUTE stmt USING @s, @c, @t1;
    ELSE EXECUTE stmt USING @s, @c;
    END IF;
    
    DEALLOCATE PREPARE stmt;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_academic_context` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_academic_context`(
    IN p_user_id INT
)
BEGIN
    SELECT university_id, faculty_id, department_id, course_id, specialization_id, class_id
    FROM content_viewer_users
    WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_active_api_routes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_api_routes`()
BEGIN
    SELECT route_path, servlet_name
    FROM api_routes
    WHERE is_active = TRUE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_chapters_by_subject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_chapters_by_subject`(IN p_subject_id INT)
BEGIN
    SELECT chapter_id, chapter_name, introduction, content, display_order
    FROM chapter
    WHERE subject_id = p_subject_id
    ORDER BY COALESCE(display_order, chapter_id) ASC, chapter_id ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_chapter_content` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_chapter_content`(
    IN p_subject_id INT
)
BEGIN
    SELECT chapter_id, chapter_name, introduction, content, summary, display_order
    FROM chapter
    WHERE subject_id = p_subject_id
    ORDER BY COALESCE(display_order, chapter_id) ASC, chapter_id ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_creator_subjects` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_creator_subjects`(IN p_user_id INT)
BEGIN
    SELECT s.subject_id, s.subject_name
    FROM subject s
    JOIN content_developer_privileges_subject cdp ON s.subject_id = cdp.subject_id
    WHERE cdp.user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_learning_content` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_learning_content`()
BEGIN
    SELECT id, title, content_type, resource_url, created_by, created_at
    FROM learning_content
    ORDER BY id DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_next_node_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_next_node_id`(
    IN p_table_name VARCHAR(64),
    IN p_id_column VARCHAR(64),
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT
)
BEGIN
    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;

    SET @query = CONCAT('SELECT COALESCE(MAX(', p_id_column, '), 0) + 1 AS next_id FROM ', p_table_name, 
                       ' WHERE subject_id = ?');
    
    IF p_table_name <> 'chapter' THEN
        SET @query = CONCAT(@query, ' AND chapter_id = ?');
        IF p_p1 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level1_id = ?'); END IF;
        IF p_p2 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level2_id = ?'); END IF;
        IF p_p3 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level3_id = ?'); END IF;
        IF p_p4 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level4_id = ?'); END IF;
    END IF;
    
    PREPARE stmt FROM @query;
    
    IF p_table_name = 'chapter' THEN
        EXECUTE stmt USING @s;
    ELSEIF p_p4 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
    ELSEIF p_p3 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
    ELSEIF p_p2 > 0 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
    ELSEIF p_p1 > 0 THEN EXECUTE stmt USING @s, @c, @t1;
    ELSE EXECUTE stmt USING @s, @c;
    END IF;
    
    DEALLOCATE PREPARE stmt;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_subjects` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_subjects`(
    IN p_university_id INT,
    IN p_faculty_id INT,
    IN p_department_id INT,
    IN p_course_id INT,
    IN p_specialization_id INT,
    IN p_class_id INT
)
BEGIN
    SELECT subject_name, subject_id
    FROM subject
    WHERE subject_id IN
    (SELECT subject_id
        FROM class_subject 
        WHERE university_id=p_university_id
        AND faculty_id=p_faculty_id 
        AND department_id=p_department_id
        AND course_id=p_course_id
        AND specialization_id=p_specialization_id 
        AND class_id=p_class_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_topics_by_parent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_topics_by_parent`(
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_target_level INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT
)
BEGIN
    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;
    
    SET @tableName = CONCAT('topic_level', p_target_level);
    SET @idColumn = CONCAT(@tableName, '_id');
    SET @nameColumn = CONCAT(@tableName, '_name');
    
    SET @query = CONCAT('SELECT ', @idColumn, ', ', @nameColumn, ', introduction, content, display_order FROM ', @tableName, 
                       ' WHERE subject_id = ? AND chapter_id = ?');
    
    IF p_target_level > 1 THEN SET @query = CONCAT(@query, ' AND topic_level1_id = ?'); END IF;
    IF p_target_level > 2 THEN SET @query = CONCAT(@query, ' AND topic_level2_id = ?'); END IF;
    IF p_target_level > 3 THEN SET @query = CONCAT(@query, ' AND topic_level3_id = ?'); END IF;
    IF p_target_level > 4 THEN SET @query = CONCAT(@query, ' AND topic_level4_id = ?'); END IF;
    
    SET @query = CONCAT(@query, ' ORDER BY COALESCE(display_order, ', @idColumn, ') ASC, ', @idColumn, ' ASC');
    
    PREPARE stmt FROM @query;
    
    IF p_target_level = 1 THEN EXECUTE stmt USING @s, @c;
    ELSEIF p_target_level = 2 THEN EXECUTE stmt USING @s, @c, @t1;
    ELSEIF p_target_level = 3 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
    ELSEIF p_target_level = 4 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
    ELSEIF p_target_level = 5 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
    END IF;
    
    DEALLOCATE PREPARE stmt;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_viewer_enabled_chapters` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_viewer_enabled_chapters`(
    IN p_user_id INT,
    IN p_subject_id INT
)
BEGIN
    SELECT ch.chapter_id, ch.chapter_name, ch.introduction, ch.content, ch.summary, ch.display_order
    FROM content_viewer_users cvu
    JOIN class_subject_chapter csc
      ON csc.university_id = cvu.university_id
     AND csc.faculty_id = cvu.faculty_id
     AND csc.department_id = cvu.department_id
     AND csc.course_id = cvu.course_id
     AND csc.specialization_id = cvu.specialization_id
     AND csc.class_id = cvu.class_id
    JOIN chapter ch
      ON ch.subject_id = csc.subject_id
     AND ch.chapter_id = csc.chapter_id
    WHERE cvu.user_id = p_user_id
      AND csc.subject_id = p_subject_id
    ORDER BY COALESCE(ch.display_order, ch.chapter_id) ASC, ch.chapter_id ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_chapter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_chapter`(in sub_id int(5), in ch_id int(2), in chapter_name varchar(200), in intro longtext, in content longtext, in summary longtext)
BEGIN
insert into chapter(
subject_id,chapter_id,chapter_name,introduction,content,summary,has_next_level,has_links,has_exercise,has_solutions,has_image,has_simulation,has_audio,has_video,has_animation,has_table,has_program,
created_at,updated_at,created_by,updated_by,review_status,approved_by,approved_at,published_at,version_no,parent_version_id,is_published
) 
values(
sub_id,ch_id,chapter_name,intro,content,summary,'0','0','0','0','0','0','0','0','0','0','0',
NOW(),NULL,NULL,NULL,'Draft',NULL,NULL,NULL,1,NULL,0
);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_chapter_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_chapter_creator`(
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_chapter_cd VARCHAR(20),
    IN p_chapter_name VARCHAR(200),
    IN p_introduction LONGTEXT,
    IN p_content LONGTEXT,
    IN p_created_by INT
)
BEGIN
    DECLARE v_max_display_order INT DEFAULT 0;
    DECLARE v_display_order INT DEFAULT 1;

    SELECT COALESCE(MAX(display_order), 0) INTO v_max_display_order
    FROM chapter
    WHERE subject_id = p_subject_id;

    IF @target_scope_level = 0
       AND @target_scope_subject_id = p_subject_id THEN
        IF @target_display_order IS NULL OR @target_display_order <= 0 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSEIF @target_display_order > v_max_display_order + 1 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSE
            SET v_display_order = @target_display_order;
        END IF;
    ELSE
        SET v_display_order = v_max_display_order + 1;
    END IF;

    INSERT INTO chapter (
        chapter_cd, subject_id, chapter_id, chapter_name, introduction, content, has_next_level,
        display_order,
        created_at, updated_at, created_by, updated_by, review_status, approved_by, approved_at,
        published_at, version_no, parent_version_id, is_published
    )
    VALUES (
        p_chapter_cd, p_subject_id, p_chapter_id, p_chapter_name, p_introduction, p_content, '0',
        v_display_order,
        NOW(), NULL, p_created_by, NULL, 'Draft', NULL, NULL,
        NULL, 1, NULL, 0
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_class` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_class`(in uni_id int(2), in faculty int(2), in dept_id int(2),in c_id int(2),in sp_id int(2),in cl_id int(2),in cl_name varchar(200), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
insert into class(university_id,faculty_id,department_id,course_id,specialization_id,class_id,class_name,responsible_person_name,responsible_person_role,responsible_person_address,responsible_person_contact_no,responsible_person_email) values(uni_id,faculty,dept_id,c_id,sp_id,cl_id,cl_name,p_responsible_person_name,p_responsible_person_role,p_responsible_person_address,p_responsible_person_contact_no,p_responsible_person_email);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_course` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_course`(in uni_id int(2), in faculty int(2), in dept_id int(2),in c_id int(2),in c_name varchar(200), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
insert into course(university_id,faculty_id,department_id,course_id,course_name,responsible_person_name,responsible_person_role,responsible_person_address,responsible_person_contact_no,responsible_person_email) values(uni_id,faculty,dept_id,c_id,c_name,p_responsible_person_name,p_responsible_person_role,p_responsible_person_address,p_responsible_person_contact_no,p_responsible_person_email);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_department` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_department`(in uni_id int(2), in faculty int(2), in dept_id int(2),in dept_name varchar(200), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
insert into department(university_id,faculty_id,department_id,department_name,responsible_person_name,responsible_person_role,responsible_person_address,responsible_person_contact_no,responsible_person_email) values(uni_id,faculty,dept_id,dept_name,p_responsible_person_name,p_responsible_person_role,p_responsible_person_address,p_responsible_person_contact_no,p_responsible_person_email);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_faculty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_faculty`(in uni_id int(2), in faculty int(2), in faculty_name varchar(200), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
 insert into faculty(university_id,faculty_id,faculty_name,responsible_person_name,responsible_person_role,responsible_person_address,responsible_person_contact_no,responsible_person_email) values(uni_id,faculty,faculty_name,p_responsible_person_name,p_responsible_person_role,p_responsible_person_address,p_responsible_person_contact_no,p_responsible_person_email);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_specialization` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_specialization`(in uni_id int(2), in faculty int(2), in dept_id int(2),in c_id int(2),in sp_id int(2),in sp_name varchar(200), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
insert into specialization(university_id,faculty_id,department_id,course_id,specialization_id,specialization_name,responsible_person_name,responsible_person_role,responsible_person_address,responsible_person_contact_no,responsible_person_email) values(uni_id,faculty,dept_id,c_id,sp_id,sp_name,p_responsible_person_name,p_responsible_person_role,p_responsible_person_address,p_responsible_person_contact_no,p_responsible_person_email);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_creator_level1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_topic_creator_level1`(
    IN p_code VARCHAR(30), IN p_subject_id INT, IN p_chapter_id INT, IN p_t1 INT,
    IN p_name VARCHAR(200), IN p_intro LONGTEXT, IN p_content LONGTEXT, IN p_created_by INT
)
BEGIN
    DECLARE v_max_display_order INT DEFAULT 0;
    DECLARE v_display_order INT DEFAULT 1;

    SELECT COALESCE(MAX(display_order), 0) INTO v_max_display_order
    FROM topic_level1
    WHERE subject_id = p_subject_id
      AND chapter_id = p_chapter_id;

    IF @target_scope_level = 1
       AND @target_scope_subject_id = p_subject_id
       AND @target_scope_chapter_id = p_chapter_id THEN
        IF @target_display_order IS NULL OR @target_display_order <= 0 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSEIF @target_display_order > v_max_display_order + 1 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSE
            SET v_display_order = @target_display_order;
        END IF;
    ELSE
        SET v_display_order = v_max_display_order + 1;
    END IF;

    INSERT INTO topic_level1 (
        topic_level1_cd, subject_id, chapter_id, topic_level1_id, topic_level1_name, introduction, content, has_next_level,
        display_order,
        created_at, updated_at, created_by, updated_by, review_status, approved_by, approved_at,
        published_at, version_no, parent_version_id, is_published
    )
    VALUES (
        p_code, p_subject_id, p_chapter_id, p_t1, p_name, p_intro, p_content, '0',
        v_display_order,
        NOW(), NULL, p_created_by, NULL, 'Draft', NULL, NULL,
        NULL, 1, NULL, 0
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_creator_level2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_topic_creator_level2`(
    IN p_code VARCHAR(30), IN p_subject_id INT, IN p_chapter_id INT, IN p_t1 INT, IN p_t2 INT,
    IN p_name VARCHAR(200), IN p_intro LONGTEXT, IN p_content LONGTEXT, IN p_created_by INT
)
BEGIN
    DECLARE v_max_display_order INT DEFAULT 0;
    DECLARE v_display_order INT DEFAULT 1;

    SELECT COALESCE(MAX(display_order), 0) INTO v_max_display_order
    FROM topic_level2
    WHERE subject_id = p_subject_id
      AND chapter_id = p_chapter_id
      AND topic_level1_id = p_t1;

    IF @target_scope_level = 2
       AND @target_scope_subject_id = p_subject_id
       AND @target_scope_chapter_id = p_chapter_id
       AND @target_scope_p1 = p_t1 THEN
        IF @target_display_order IS NULL OR @target_display_order <= 0 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSEIF @target_display_order > v_max_display_order + 1 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSE
            SET v_display_order = @target_display_order;
        END IF;
    ELSE
        SET v_display_order = v_max_display_order + 1;
    END IF;

    INSERT INTO topic_level2 (
        topic_level2_cd, subject_id, chapter_id, topic_level1_id, topic_level2_id, topic_level2_name, introduction, content, has_next_level,
        display_order,
        created_at, updated_at, created_by, updated_by, review_status, approved_by, approved_at,
        published_at, version_no, parent_version_id, is_published
    )
    VALUES (
        p_code, p_subject_id, p_chapter_id, p_t1, p_t2, p_name, p_intro, p_content, '0',
        v_display_order,
        NOW(), NULL, p_created_by, NULL, 'Draft', NULL, NULL,
        NULL, 1, NULL, 0
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_creator_level3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_topic_creator_level3`(
    IN p_code VARCHAR(30), IN p_subject_id INT, IN p_chapter_id INT, IN p_t1 INT, IN p_t2 INT, IN p_t3 INT,
    IN p_name VARCHAR(200), IN p_intro LONGTEXT, IN p_content LONGTEXT, IN p_created_by INT
)
BEGIN
    DECLARE v_max_display_order INT DEFAULT 0;
    DECLARE v_display_order INT DEFAULT 1;

    SELECT COALESCE(MAX(display_order), 0) INTO v_max_display_order
    FROM topic_level3
    WHERE subject_id = p_subject_id
      AND chapter_id = p_chapter_id
      AND topic_level1_id = p_t1
      AND topic_level2_id = p_t2;

    IF @target_scope_level = 3
       AND @target_scope_subject_id = p_subject_id
       AND @target_scope_chapter_id = p_chapter_id
       AND @target_scope_p1 = p_t1
       AND @target_scope_p2 = p_t2 THEN
        IF @target_display_order IS NULL OR @target_display_order <= 0 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSEIF @target_display_order > v_max_display_order + 1 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSE
            SET v_display_order = @target_display_order;
        END IF;
    ELSE
        SET v_display_order = v_max_display_order + 1;
    END IF;

    INSERT INTO topic_level3 (
        topic_level3_cd, subject_id, chapter_id, topic_level1_id, topic_level2_id, topic_level3_id, topic_level3_name, introduction, content, has_next_level,
        display_order,
        created_at, updated_at, created_by, updated_by, review_status, approved_by, approved_at,
        published_at, version_no, parent_version_id, is_published
    )
    VALUES (
        p_code, p_subject_id, p_chapter_id, p_t1, p_t2, p_t3, p_name, p_intro, p_content, '0',
        v_display_order,
        NOW(), NULL, p_created_by, NULL, 'Draft', NULL, NULL,
        NULL, 1, NULL, 0
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_creator_level4` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_topic_creator_level4`(
    IN p_code VARCHAR(30), IN p_subject_id INT, IN p_chapter_id INT, IN p_t1 INT, IN p_t2 INT, IN p_t3 INT, IN p_t4 INT,
    IN p_name VARCHAR(200), IN p_intro LONGTEXT, IN p_content LONGTEXT, IN p_created_by INT
)
BEGIN
    DECLARE v_max_display_order INT DEFAULT 0;
    DECLARE v_display_order INT DEFAULT 1;

    SELECT COALESCE(MAX(display_order), 0) INTO v_max_display_order
    FROM topic_level4
    WHERE subject_id = p_subject_id
      AND chapter_id = p_chapter_id
      AND topic_level1_id = p_t1
      AND topic_level2_id = p_t2
      AND topic_level3_id = p_t3;

    IF @target_scope_level = 4
       AND @target_scope_subject_id = p_subject_id
       AND @target_scope_chapter_id = p_chapter_id
       AND @target_scope_p1 = p_t1
       AND @target_scope_p2 = p_t2
       AND @target_scope_p3 = p_t3 THEN
        IF @target_display_order IS NULL OR @target_display_order <= 0 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSEIF @target_display_order > v_max_display_order + 1 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSE
            SET v_display_order = @target_display_order;
        END IF;
    ELSE
        SET v_display_order = v_max_display_order + 1;
    END IF;

    INSERT INTO topic_level4 (
        topic_level4_cd, subject_id, chapter_id, topic_level1_id, topic_level2_id, topic_level3_id, topic_level4_id, topic_level4_name, introduction, content, has_next_level,
        display_order,
        created_at, updated_at, created_by, updated_by, review_status, approved_by, approved_at,
        published_at, version_no, parent_version_id, is_published
    )
    VALUES (
        p_code, p_subject_id, p_chapter_id, p_t1, p_t2, p_t3, p_t4, p_name, p_intro, p_content, '0',
        v_display_order,
        NOW(), NULL, p_created_by, NULL, 'Draft', NULL, NULL,
        NULL, 1, NULL, 0
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_creator_level5` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_topic_creator_level5`(
    IN p_code VARCHAR(30), IN p_subject_id INT, IN p_chapter_id INT, IN p_t1 INT, IN p_t2 INT, IN p_t3 INT, IN p_t4 INT, IN p_t5 INT,
    IN p_name VARCHAR(200), IN p_intro LONGTEXT, IN p_content LONGTEXT, IN p_created_by INT
)
BEGIN
    DECLARE v_max_display_order INT DEFAULT 0;
    DECLARE v_display_order INT DEFAULT 1;

    SELECT COALESCE(MAX(display_order), 0) INTO v_max_display_order
    FROM topic_level5
    WHERE subject_id = p_subject_id
      AND chapter_id = p_chapter_id
      AND topic_level1_id = p_t1
      AND topic_level2_id = p_t2
      AND topic_level3_id = p_t3
      AND topic_level4_id = p_t4;

    IF @target_scope_level = 5
       AND @target_scope_subject_id = p_subject_id
       AND @target_scope_chapter_id = p_chapter_id
       AND @target_scope_p1 = p_t1
       AND @target_scope_p2 = p_t2
       AND @target_scope_p3 = p_t3
       AND @target_scope_p4 = p_t4 THEN
        IF @target_display_order IS NULL OR @target_display_order <= 0 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSEIF @target_display_order > v_max_display_order + 1 THEN
            SET v_display_order = v_max_display_order + 1;
        ELSE
            SET v_display_order = @target_display_order;
        END IF;
    ELSE
        SET v_display_order = v_max_display_order + 1;
    END IF;

    INSERT INTO topic_level5 (
        topic_level5_cd, subject_id, chapter_id, topic_level1_id, topic_level2_id, topic_level3_id, topic_level4_id, topic_level5_id, topic_level5_name, introduction, content, has_next_level,
        display_order,
        created_at, updated_at, created_by, updated_by, review_status, approved_by, approved_at,
        published_at, version_no, parent_version_id, is_published
    )
    VALUES (
        p_code, p_subject_id, p_chapter_id, p_t1, p_t2, p_t3, p_t4, p_t5, p_name, p_intro, p_content, '0',
        v_display_order,
        NOW(), NULL, p_created_by, NULL, 'Draft', NULL, NULL,
        NULL, 1, NULL, 0
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_level1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_topic_level1`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_name varchar(200), in intro longtext, in content longtext, in summary longtext)
BEGIN
insert into topic_level1(
subject_id,chapter_id,topic_level1_id,topic_level1_name,introduction,content,summary,has_next_level,has_links,has_exercise,has_solutions,has_image,has_simulation,has_Audio,has_video,has_animation,has_table,
created_at,updated_at,created_by,updated_by,review_status,approved_by,approved_at,published_at,version_no,parent_version_id,is_published
) 
values(
sub_id,ch_id,topic_l1_id,topic_name,intro,content,summary,'0','0','0','0','0','0','0','0','0','0',
NOW(),NULL,NULL,NULL,'Draft',NULL,NULL,NULL,1,NULL,0
);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_level2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_topic_level2`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_name varchar(200), in intro longtext, in content longtext, in summary longtext)
BEGIN
insert into topic_level2(
subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level2_name,introduction,content,summary,has_next_level,has_links,has_exercise,has_solutions,has_image,has_simulation,has_Audio,has_video,has_animation,has_table,
created_at,updated_at,created_by,updated_by,review_status,approved_by,approved_at,published_at,version_no,parent_version_id,is_published
) 
values(
sub_id,ch_id,topic_l1_id,topic_l2_id,topic_name,intro,content,summary,'0','0','0','0','0','0','0','0','0','0',
NOW(),NULL,NULL,NULL,'Draft',NULL,NULL,NULL,1,NULL,0
);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_level3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_topic_level3`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_l3_id int(2), in topic_name varchar(200), in intro longtext, in content longtext, in summary longtext)
BEGIN
insert into topic_level3(
subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id,topic_level3_name,introduction,content,summary,has_next_level,has_links,has_exercise,has_solutions,has_image,has_simulation,has_Audio,has_video,has_animation,has_table,
created_at,updated_at,created_by,updated_by,review_status,approved_by,approved_at,published_at,version_no,parent_version_id,is_published
) 
values(
sub_id,ch_id,topic_l1_id,topic_l2_id,topic_l3_id,topic_name,intro,content,summary,'0','0','0','0','0','0','0','0','0','0',
NOW(),NULL,NULL,NULL,'Draft',NULL,NULL,NULL,1,NULL,0
);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_level4` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_topic_level4`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_l3_id int(2),in topic_l4_id int(2), in topic_name varchar(200), in intro longtext, in content longtext, in summary longtext)
BEGIN
insert into topic_level4(
subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id,topic_level4_id,topic_level4_name,introduction,content,summary,has_next_level,has_links,has_exercise,has_solutions,has_image,has_simulation,has_Audio,has_video,has_animation,has_table,
created_at,updated_at,created_by,updated_by,review_status,approved_by,approved_at,published_at,version_no,parent_version_id,is_published
) 
values(
sub_id,ch_id,topic_l1_id,topic_l2_id,topic_l3_id,topic_l4_id,topic_name,intro,content,summary,'0','0','0','0','0','0','0','0','0','0',
NOW(),NULL,NULL,NULL,'Draft',NULL,NULL,NULL,1,NULL,0
);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_topic_level5` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `insert_topic_level5`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_l3_id int(2),in topic_l4_id int(2),in topic_l5_id int(2), in topic_name varchar(200), in intro longtext, in content longtext, in summary longtext)
BEGIN
insert into topic_level5(
subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id,topic_level4_id,topic_level5_id,topic_level5_name,introduction,content,summary,has_next_level,has_links,has_exercise,has_solutions,has_image,has_simulation,has_Audio,has_video,has_animation,has_table,
created_at,updated_at,created_by,updated_by,review_status,approved_by,approved_at,published_at,version_no,parent_version_id,is_published
) 
values(
sub_id,ch_id,topic_l1_id,topic_l2_id,topic_l3_id,topic_l4_id,topic_l5_id,topic_name,intro,content,summary,'0','0','0','0','0','0','0','0','0','0',
NOW(),NULL,NULL,NULL,'Draft',NULL,NULL,NULL,1,NULL,0
);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `normalize_display_order_scope_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `normalize_display_order_scope_creator`(
    IN p_level INT,
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT
)
BEGIN
    DECLARE v_table_name VARCHAR(64);
    DECLARE v_id_column VARCHAR(64);
    DECLARE v_scope_sql LONGTEXT;

    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;

    IF p_level = 0 THEN
        SET v_table_name = 'chapter';
        SET v_id_column = 'chapter_id';
    ELSE
        SET v_table_name = CONCAT('topic_level', p_level);
        SET v_id_column = CONCAT(v_table_name, '_id');
    END IF;

    SET v_scope_sql = ' WHERE subject_id = ?';
    IF p_level > 0 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND chapter_id = ?'); END IF;
    IF p_level > 1 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level1_id = ?'); END IF;
    IF p_level > 2 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level2_id = ?'); END IF;
    IF p_level > 3 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level3_id = ?'); END IF;
    IF p_level > 4 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level4_id = ?'); END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_creator_display_scope;
    CREATE TEMPORARY TABLE tmp_creator_display_scope (
        node_id INT NOT NULL PRIMARY KEY,
        seq_no INT NOT NULL
    ) ENGINE=MEMORY;

    SET @query = CONCAT(
        'INSERT INTO tmp_creator_display_scope (node_id, seq_no) ',
        'SELECT ordered.', v_id_column, ', (@rownum := @rownum + 1) AS seq_no ',
        'FROM (SELECT ', v_id_column, ' FROM ', v_table_name, v_scope_sql,
        ' ORDER BY COALESCE(display_order, ', v_id_column, '), ', v_id_column, ') ordered ',
        'JOIN (SELECT @rownum := 0) rn'
    );
    PREPARE stmt FROM @query;
    IF p_level = 0 THEN EXECUTE stmt USING @s;
    ELSEIF p_level = 1 THEN EXECUTE stmt USING @s, @c;
    ELSEIF p_level = 2 THEN EXECUTE stmt USING @s, @c, @t1;
    ELSEIF p_level = 3 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
    ELSEIF p_level = 4 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
    ELSEIF p_level = 5 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
    END IF;
    DEALLOCATE PREPARE stmt;

    SET @query = CONCAT(
        'UPDATE ', v_table_name, ' t ',
        'JOIN tmp_creator_display_scope s ON t.', v_id_column, ' = s.node_id ',
        'SET t.display_order = s.seq_no',
        v_scope_sql
    );
    PREPARE stmt FROM @query;
    IF p_level = 0 THEN EXECUTE stmt USING @s;
    ELSEIF p_level = 1 THEN EXECUTE stmt USING @s, @c;
    ELSEIF p_level = 2 THEN EXECUTE stmt USING @s, @c, @t1;
    ELSEIF p_level = 3 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
    ELSEIF p_level = 4 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
    ELSEIF p_level = 5 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
    END IF;
    DEALLOCATE PREPARE stmt;

    DROP TEMPORARY TABLE IF EXISTS tmp_creator_display_scope;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `prepare_display_order_slot_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `prepare_display_order_slot_creator`(
    IN p_level INT,
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT,
    IN p_requested_display_order INT
)
BEGIN
    DECLARE v_table_name VARCHAR(64);
    DECLARE v_id_column VARCHAR(64);
    DECLARE v_scope_sql LONGTEXT;
    DECLARE v_parent_table VARCHAR(64);
    DECLARE v_parent_scope_sql LONGTEXT;
    DECLARE v_max_display_order INT DEFAULT 0;
    DECLARE v_target_display_order INT DEFAULT 1;

    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;

    IF p_level = 0 THEN
        SET v_table_name = 'chapter';
        SET v_id_column = 'chapter_id';
    ELSE
        SET v_table_name = CONCAT('topic_level', p_level);
        SET v_id_column = CONCAT(v_table_name, '_id');
    END IF;

    SET v_scope_sql = ' WHERE subject_id = ?';
    IF p_level > 0 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND chapter_id = ?'); END IF;
    IF p_level > 1 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level1_id = ?'); END IF;
    IF p_level > 2 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level2_id = ?'); END IF;
    IF p_level > 3 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level3_id = ?'); END IF;
    IF p_level > 4 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level4_id = ?'); END IF;

    IF p_level = 0 THEN
        SELECT subject_id FROM subject WHERE subject_id = p_subject_id FOR UPDATE;
    ELSE
        SET v_parent_table = IF(p_level = 1, 'chapter', CONCAT('topic_level', p_level - 1));
        SET v_parent_scope_sql = ' WHERE subject_id = ? AND chapter_id = ?';
        IF p_level > 1 THEN SET v_parent_scope_sql = CONCAT(v_parent_scope_sql, ' AND topic_level1_id = ?'); END IF;
        IF p_level > 2 THEN SET v_parent_scope_sql = CONCAT(v_parent_scope_sql, ' AND topic_level2_id = ?'); END IF;
        IF p_level > 3 THEN SET v_parent_scope_sql = CONCAT(v_parent_scope_sql, ' AND topic_level3_id = ?'); END IF;
        IF p_level > 4 THEN SET v_parent_scope_sql = CONCAT(v_parent_scope_sql, ' AND topic_level4_id = ?'); END IF;

        SET @query = CONCAT('SELECT 1 FROM ', v_parent_table, v_parent_scope_sql, ' FOR UPDATE');
        PREPARE stmt FROM @query;
        IF p_level = 1 THEN EXECUTE stmt USING @s, @c;
        ELSEIF p_level = 2 THEN EXECUTE stmt USING @s, @c, @t1;
        ELSEIF p_level = 3 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
        ELSEIF p_level = 4 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
        ELSEIF p_level = 5 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
        END IF;
        DEALLOCATE PREPARE stmt;
    END IF;

    CALL normalize_display_order_scope_creator(p_level, p_subject_id, p_chapter_id, p_p1, p_p2, p_p3, p_p4);

    SET @max_display_order = 0;
    SET @query = CONCAT('SELECT COALESCE(MAX(display_order), 0) INTO @max_display_order FROM ', v_table_name, v_scope_sql);
    PREPARE stmt FROM @query;
    IF p_level = 0 THEN EXECUTE stmt USING @s;
    ELSEIF p_level = 1 THEN EXECUTE stmt USING @s, @c;
    ELSEIF p_level = 2 THEN EXECUTE stmt USING @s, @c, @t1;
    ELSEIF p_level = 3 THEN EXECUTE stmt USING @s, @c, @t1, @t2;
    ELSEIF p_level = 4 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3;
    ELSEIF p_level = 5 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4;
    END IF;
    DEALLOCATE PREPARE stmt;
    SET v_max_display_order = IFNULL(@max_display_order, 0);

    IF p_requested_display_order IS NULL OR p_requested_display_order <= 0 THEN
        SET v_target_display_order = v_max_display_order + 1;
    ELSEIF p_requested_display_order > v_max_display_order + 1 THEN
        SET v_target_display_order = v_max_display_order + 1;
    ELSE
        SET v_target_display_order = p_requested_display_order;
    END IF;

    SET @target_display_order = v_target_display_order;
    SET @target_scope_level = p_level;
    SET @target_scope_subject_id = p_subject_id;
    SET @target_scope_chapter_id = p_chapter_id;
    SET @target_scope_p1 = p_p1;
    SET @target_scope_p2 = p_p2;
    SET @target_scope_p3 = p_p3;
    SET @target_scope_p4 = p_p4;

    SET @query = CONCAT(
        'UPDATE ', v_table_name, ' SET display_order = display_order + 1',
        v_scope_sql,
        ' AND COALESCE(display_order, 0) >= ?'
    );
    PREPARE stmt FROM @query;
    IF p_level = 0 THEN EXECUTE stmt USING @s, @target_display_order;
    ELSEIF p_level = 1 THEN EXECUTE stmt USING @s, @c, @target_display_order;
    ELSEIF p_level = 2 THEN EXECUTE stmt USING @s, @c, @t1, @target_display_order;
    ELSEIF p_level = 3 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @target_display_order;
    ELSEIF p_level = 4 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @target_display_order;
    ELSEIF p_level = 5 THEN EXECUTE stmt USING @s, @c, @t1, @t2, @t3, @t4, @target_display_order;
    END IF;
    DEALLOCATE PREPARE stmt;

    SELECT v_target_display_order AS target_display_order;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_code_topic_level_1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `set_code_topic_level_1`(in sub_id int(5))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id FROM topic_level1
							WHERE subject_id=sub_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level1 set topic_level1_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1;
	END LOOP;
    CLOSE cur1;
    call cascade_code_topic_2(sub_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_code_topic_level_2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `set_code_topic_level_2`(in sub_id int(5), in ch_id int(2))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id FROM topic_level2 
							WHERE subject_id=sub_id 
                            AND chapter_id=ch_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level2 set topic_level2_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2;
	END LOOP;
    CLOSE cur1;
    call cascade_code_topic_3(sub_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_code_topic_level_3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `set_code_topic_level_3`(in sub_id int(5), in ch_id int(2), in topic_level1 int(2))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2,t3 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id FROM topic_level3 
							WHERE subject_id=sub_id 
                            AND chapter_id=ch_id 
                            AND topic_level1_id = topic_level1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2,t3;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level3 set topic_level3_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0),lpad(t3,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2 
            AND topic_level3_id = t3;
	END LOOP;
    CLOSE cur1;
    call cascade_code_topic_4(sub_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_code_topic_level_4` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `set_code_topic_level_4`(in sub_id int(5), in ch_id int(2), in topic_level1 int(2), in topic_level2 int(2))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2,t3,t4 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id,topic_level4_id FROM topic_level4 
							WHERE subject_id=sub_id 
                            AND chapter_id=ch_id 
                            AND topic_level1_id = topic_level1 
                            AND topic_level2_id = topic_level2;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2,t3,t4;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level4 set topic_level4_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0),lpad(t3,2,0),lpad(t4,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2 
            AND topic_level3_id = t3
            AND topic_level4_id = t4;
	END LOOP;
    CLOSE cur1;
    call cascade_code_topic_4(sub_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_code_topic_level_5` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `set_code_topic_level_5`(in sub_id int(5), in ch_id int(2), in topic_level1 int(2), in topic_level2 int(2), in topic_level3 int(2))
BEGIN
	DECLARE done INT DEFAULT FALSE;
    DECLARE sub,ch,t1,t2,t3,t4,t5 INT;
    DECLARE cur1 CURSOR FOR SELECT subject_id,chapter_id,topic_level1_id,topic_level2_id,topic_level3_id,topic_level4_id,topic_level5_id FROM topic_level5
							WHERE subject_id=sub_id 
                            AND chapter_id=ch_id 
                            AND topic_level1_id = topic_level1 
                            AND topic_level2_id = topic_level2
                            AND topic_level3_id = topic_level3;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur1;
    read_loop: LOOP
		FETCH cur1 into sub,ch,t1,t2,t3,t4,t5;
        IF done THEN
			LEAVE read_loop;
		END IF;
        UPDATE topic_level5 set topic_level5_cd = concat(lpad(sub,5,0),lpad(ch,2,0),lpad(t1,2,0),lpad(t2,2,0),lpad(t3,2,0),lpad(t4,2,0),lpad(t5,2,0))
			WHERE subject_id = sub  
            AND chapter_id = ch 
            AND topic_level1_id = t1 
            AND topic_level2_id = t2 
            AND topic_level3_id = t3
            AND topic_level4_id = t4
            AND topic_level5_id = t5;
	END LOOP;
    
    CLOSE cur1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `set_node_display_order_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `set_node_display_order_creator`(
    IN p_level INT,
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT,
    IN p_node_id INT,
    IN p_display_order INT
)
BEGIN
    DECLARE v_table_name VARCHAR(64);
    DECLARE v_id_column VARCHAR(64);
    DECLARE v_scope_sql LONGTEXT;

    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;
    SET @n = p_node_id;
    SET @d = IF(p_display_order IS NULL OR p_display_order <= 0, 1, p_display_order);

    IF p_level = 0 THEN
        SET v_table_name = 'chapter';
        SET v_id_column = 'chapter_id';
    ELSE
        SET v_table_name = CONCAT('topic_level', p_level);
        SET v_id_column = CONCAT(v_table_name, '_id');
    END IF;

    SET v_scope_sql = ' WHERE subject_id = ?';
    IF p_level > 0 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND chapter_id = ?'); END IF;
    IF p_level > 1 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level1_id = ?'); END IF;
    IF p_level > 2 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level2_id = ?'); END IF;
    IF p_level > 3 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level3_id = ?'); END IF;
    IF p_level > 4 THEN SET v_scope_sql = CONCAT(v_scope_sql, ' AND topic_level4_id = ?'); END IF;

    SET @query = CONCAT('UPDATE ', v_table_name, ' SET display_order = ?',
                        v_scope_sql, ' AND ', v_id_column, ' = ?');
    PREPARE stmt FROM @query;
    IF p_level = 0 THEN EXECUTE stmt USING @d, @s, @n;
    ELSEIF p_level = 1 THEN EXECUTE stmt USING @d, @s, @c, @n;
    ELSEIF p_level = 2 THEN EXECUTE stmt USING @d, @s, @c, @t1, @n;
    ELSEIF p_level = 3 THEN EXECUTE stmt USING @d, @s, @c, @t1, @t2, @n;
    ELSEIF p_level = 4 THEN EXECUTE stmt USING @d, @s, @c, @t1, @t2, @t3, @n;
    ELSEIF p_level = 5 THEN EXECUTE stmt USING @d, @s, @c, @t1, @t2, @t3, @t4, @n;
    END IF;
    DEALLOCATE PREPARE stmt;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_class` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_class`(in uni_id int(2), in fac_id int(2),in dept_id int(2),in c_id int(2),in sp_id int(2),in cl_id int(2) ,in cl_name varchar(200), in co_name varchar(50), in dur int(1),in room varchar(5), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
update class set class_name = cl_name,co_ordinator=co_name,duration=dur,room_no=room,responsible_person_name=p_responsible_person_name,responsible_person_role=p_responsible_person_role,responsible_person_address=p_responsible_person_address,responsible_person_contact_no=p_responsible_person_contact_no,responsible_person_email=p_responsible_person_email
where university_id = uni_id and faculty_id = fac_id and department_id = dept_id and course_id=c_id and specialization_id = sp_id and class_id = cl_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_course` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_course`(in uni_id int(2), in fac_id int(2),in dept_id int(2),in c_id int(2),in c_name varchar(200), in co_name varchar(50), in dur int(1),in addr varchar(200), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
update course set course_name = c_name,co_ordinator=co_name,duration=dur,address=addr,responsible_person_name=p_responsible_person_name,responsible_person_role=p_responsible_person_role,responsible_person_address=p_responsible_person_address,responsible_person_contact_no=p_responsible_person_contact_no,responsible_person_email=p_responsible_person_email
where university_id = uni_id and faculty_id = fac_id and department_id = dept_id and course_id=c_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_department` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_department`(in uni_id int(2), in fac_id int(2),in dept_id int(2), in d_name varchar(200), in hod_name varchar(50), in email_id varchar(40),in contact varchar(15),in fax varchar(15),in addr varchar(250), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
update department set department_name = d_name,hod = hod_name,email = email_id,contact_no = contact,fax_no=fax,address = addr,responsible_person_name=p_responsible_person_name,responsible_person_role=p_responsible_person_role,responsible_person_address=p_responsible_person_address,responsible_person_contact_no=p_responsible_person_contact_no,responsible_person_email=p_responsible_person_email
where university_id = uni_id and faculty_id = fac_id and department_id = dept_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_faculty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_faculty`(in uni_id int(2), in fac_id int(2), in f_name varchar(200), in dean_name varchar(50), in email_id varchar(40),in contact varchar(15),in fax varchar(15),in addr varchar(250), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
update faculty set faculty_name = f_name,dean = dean_name,email = email_id,contact_no = contact,fax_no=fax,address = addr,responsible_person_name=p_responsible_person_name,responsible_person_role=p_responsible_person_role,responsible_person_address=p_responsible_person_address,responsible_person_contact_no=p_responsible_person_contact_no,responsible_person_email=p_responsible_person_email
where university_id = uni_id and faculty_id = fac_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_has_next_level_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_has_next_level_creator`(
    IN p_table_name VARCHAR(64),
    IN p_status CHAR(1),
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT
)
BEGIN
    SET @status = p_status;
    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;

    SET @query = CONCAT('UPDATE ', p_table_name, ' SET has_next_level = ?');
    
    IF p_table_name LIKE 'topic_level%' THEN
        SET @query = CONCAT(@query, ', updated_at = NOW(), version_no = COALESCE(version_no, 0) + 1');
    END IF;
    
    SET @query = CONCAT(@query, ' WHERE subject_id = ? AND chapter_id = ?');
    
    IF p_table_name LIKE 'topic_level%' THEN
        IF p_p1 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level1_id = ?'); END IF;
        IF p_p2 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level2_id = ?'); END IF;
        IF p_p3 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level3_id = ?'); END IF;
        IF p_p4 > 0 THEN SET @query = CONCAT(@query, ' AND topic_level4_id = ?'); END IF;
    END IF;
    
    PREPARE stmt FROM @query;
    
    IF p_table_name = 'chapter' THEN EXECUTE stmt USING @status, @s, @c;
    ELSEIF p_p4 > 0 THEN EXECUTE stmt USING @status, @s, @c, @t1, @t2, @t3, @t4;
    ELSEIF p_p3 > 0 THEN EXECUTE stmt USING @status, @s, @c, @t1, @t2, @t3;
    ELSEIF p_p2 > 0 THEN EXECUTE stmt USING @status, @s, @c, @t1, @t2;
    ELSEIF p_p1 > 0 THEN EXECUTE stmt USING @status, @s, @c, @t1;
    ELSE EXECUTE stmt USING @status, @s, @c;
    END IF;
    
    DEALLOCATE PREPARE stmt;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_node_content_creator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_node_content_creator`(
    IN p_subject_id INT,
    IN p_chapter_id INT,
    IN p_level INT, 
    IN p_p1 INT,
    IN p_p2 INT,
    IN p_p3 INT,
    IN p_p4 INT,
    IN p_p5 INT,
    IN p_title TEXT,
    IN p_content TEXT
)
BEGIN
    SET @s = p_subject_id;
    SET @c = p_chapter_id;
    SET @t1 = p_p1;
    SET @t2 = p_p2;
    SET @t3 = p_p3;
    SET @t4 = p_p4;
    SET @t5 = p_p5;
    SET @title = p_title;
    SET @content = p_content;

    IF p_level = 0 THEN
        UPDATE chapter 
        SET chapter_name = p_title,
            introduction = CASE WHEN COALESCE(NULLIF(content, ''), '') = '' THEN p_content ELSE introduction END,
            content = CASE WHEN COALESCE(NULLIF(content, ''), '') <> '' OR COALESCE(NULLIF(introduction, ''), '') = '' THEN p_content ELSE content END
        WHERE subject_id = p_subject_id AND chapter_id = p_chapter_id;
    ELSE
        SET @tableName = CONCAT('topic_level', p_level);
        SET @nameColumn = CONCAT(@tableName, '_name');
        SET @query = CONCAT('UPDATE ', @tableName, 
                           ' SET ', @nameColumn, ' = ?, ',
                           ' introduction = CASE WHEN COALESCE(NULLIF(content, \'\'), \'\') = \'\' THEN ? ELSE introduction END, ',
                           ' content = CASE WHEN COALESCE(NULLIF(content, \'\'), \'\') <> \'\' OR COALESCE(NULLIF(introduction, \'\'), \'\') = \'\' THEN ? ELSE content END, ',
                           ' updated_at = NOW(), ',
                           ' version_no = COALESCE(version_no, 0) + 1 ',
                           ' WHERE subject_id = ? AND chapter_id = ?');
        
        IF p_level >= 1 THEN SET @query = CONCAT(@query, ' AND topic_level1_id = ?'); END IF;
        IF p_level >= 2 THEN SET @query = CONCAT(@query, ' AND topic_level2_id = ?'); END IF;
        IF p_level >= 3 THEN SET @query = CONCAT(@query, ' AND topic_level3_id = ?'); END IF;
        IF p_level >= 4 THEN SET @query = CONCAT(@query, ' AND topic_level4_id = ?'); END IF;
        IF p_level >= 5 THEN SET @query = CONCAT(@query, ' AND topic_level5_id = ?'); END IF;
        
        PREPARE stmt FROM @query;
        IF p_level = 1 THEN EXECUTE stmt USING @title, @content, @content, @s, @c, @t1;
        ELSEIF p_level = 2 THEN EXECUTE stmt USING @title, @content, @content, @s, @c, @t1, @t2;
        ELSEIF p_level = 3 THEN EXECUTE stmt USING @title, @content, @content, @s, @c, @t1, @t2, @t3;
        ELSEIF p_level = 4 THEN EXECUTE stmt USING @title, @content, @content, @s, @c, @t1, @t2, @t3, @t4;
        ELSEIF p_level = 5 THEN EXECUTE stmt USING @title, @content, @content, @s, @c, @t1, @t2, @t3, @t4, @t5;
        END IF;
        DEALLOCATE PREPARE stmt;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_specialization` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_specialization`(in uni_id int(2), in fac_id int(2),in dept_id int(2),in c_id int(2),in sp_id int(2) ,in sp_name varchar(200), in co_name varchar(50), in dur int(1),in addr varchar(200), in p_responsible_person_name varchar(100), in p_responsible_person_role varchar(100), in p_responsible_person_address varchar(255), in p_responsible_person_contact_no varchar(20), in p_responsible_person_email varchar(100))
BEGIN
update specialization set specialization_name = sp_name,co_ordinator=co_name,duration=dur,address=addr,responsible_person_name=p_responsible_person_name,responsible_person_role=p_responsible_person_role,responsible_person_address=p_responsible_person_address,responsible_person_contact_no=p_responsible_person_contact_no,responsible_person_email=p_responsible_person_email
where university_id = uni_id and faculty_id = fac_id and department_id = dept_id and course_id=c_id and specialization_id = sp_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_topic_level1` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_topic_level1`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_name varchar(200), in intro longtext, in topic_content longtext, in topic_summary longtext)
BEGIN
update topic_level1 set topic_level1_name=topic_name, introduction=intro, content=topic_content, summary=topic_summary, updated_at=NOW(), version_no=COALESCE(version_no,0)+1 
where subject_id=sub_id and chapter_id=ch_id and topic_level1_id=topic_l1_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_topic_level2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_topic_level2`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_name varchar(200), in intro longtext, in topic_content longtext, in topic_summary longtext)
BEGIN
update topic_level2 set topic_level2_name=topic_name, introduction=intro, content=topic_content, summary=topic_summary, updated_at=NOW(), version_no=COALESCE(version_no,0)+1 
where subject_id=sub_id and chapter_id=ch_id and topic_level1_id=topic_l1_id and topic_level2_id=topic_l2_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_topic_level3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_topic_level3`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_l3_id int(2), in topic_name varchar(200), in intro longtext, in topic_content longtext, in topic_summary longtext)
BEGIN
update topic_level3 set topic_level3_name=topic_name, introduction=intro, content=topic_content, summary=topic_summary, updated_at=NOW(), version_no=COALESCE(version_no,0)+1 
where subject_id=sub_id and chapter_id=ch_id and topic_level1_id=topic_l1_id and topic_level2_id=topic_l2_id and topic_level3_id=topic_l3_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_topic_level4` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_topic_level4`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_l3_id int(2), in topic_l4_id int(2), in topic_name varchar(200), in intro longtext, in topic_content longtext, in topic_summary longtext)
BEGIN
update topic_level4 set topic_level4_name=topic_name, introduction=intro, content=topic_content, summary=topic_summary, updated_at=NOW(), version_no=COALESCE(version_no,0)+1 
where subject_id=sub_id and chapter_id=ch_id and topic_level1_id=topic_l1_id and topic_level2_id=topic_l2_id and topic_level3_id=topic_l3_id and topic_level4_id=topic_l4_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_topic_level5` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`wls`@`localhost` PROCEDURE `update_topic_level5`(in sub_id int(5), in ch_id int(2), in topic_l1_id int(2), in topic_l2_id int(2), in topic_l3_id int(2), in topic_l4_id int(2), in topic_l5_id int(2), in topic_name varchar(200), in intro longtext, in topic_content longtext, in topic_summary longtext)
BEGIN
update topic_level5 set topic_level5_name=topic_name, introduction=intro, content=topic_content, summary=topic_summary, updated_at=NOW(), version_no=COALESCE(version_no,0)+1 
where subject_id=sub_id and chapter_id=ch_id and topic_level1_id=topic_l1_id and topic_level2_id=topic_l2_id and topic_level3_id=topic_l3_id and topic_level4_id=topic_l4_id and topic_level5_id=topic_l5_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `user_verify` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `user_verify`(
    IN p_username VARCHAR(255)
)
BEGIN
    SELECT user_id, role_id, password_hash
    FROM users
    WHERE username = p_username;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-14  1:41:59
