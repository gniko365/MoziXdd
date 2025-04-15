-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 15, 2025 at 01:43 PM
-- Server version: 5.7.24
-- PHP Version: 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mozix`
--
CREATE DATABASE IF NOT EXISTS `mozix` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `mozix`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddRating` (IN `p_user_id` INT, IN `p_movie_id` INT, IN `p_rating` INT, IN `p_review` VARCHAR(255))   BEGIN
    INSERT INTO ratings (user_id, movie_id, rating, review, rating_date)
    VALUES (p_user_id, p_movie_id, p_rating, p_review, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CalculateAverageRatingForMovie` (IN `p_movie_id` INT)   BEGIN
    SELECT 
        m.movie_id,
        m.movie_name AS title,
        ROUND(AVG(r.rating), 1) AS average_rating,
        COUNT(r.rating_id) AS rating_count
    FROM 
        movies m
    LEFT JOIN 
        ratings r ON m.movie_id = r.movie_id
    WHERE 
        m.movie_id = p_movie_id
    GROUP BY 
        m.movie_id, m.movie_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateActor` (IN `p_name` VARCHAR(255), IN `p_birth_date` DATE, IN `p_actor_image` VARCHAR(255))   BEGIN
    INSERT INTO actors (name, birth_date, actor_image)
    VALUES (p_name, p_birth_date, p_actor_image);
    
    SELECT * FROM actors WHERE actor_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateAdmin` (IN `p_username` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255))   BEGIN
    INSERT INTO users (username, email, password, role, registration_date)
    VALUES (p_username, p_email, SHA2(p_password, 512), 'admin', NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDirector` (IN `p_name` VARCHAR(100), IN `p_director_image` VARCHAR(255), IN `p_birth_date` DATE)   BEGIN
    INSERT INTO Directors (name, director_image, birth_date)
    VALUES (p_name, p_director_image, p_birth_date);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteActor` (IN `p_actor_id` INT)   BEGIN
    DECLARE actor_count INT;
    
    SELECT COUNT(*) INTO actor_count FROM actors WHERE actor_id = p_actor_id;
    
    IF actor_count > 0 THEN
        DELETE FROM actors WHERE actor_id = p_actor_id;
        SELECT CONCAT('Actor with ID ', p_actor_id, ' deleted successfully') AS message;
    ELSE
        SELECT CONCAT('Actor with ID ', p_actor_id, ' not found') AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteDirector` (IN `p_director_id` INT)   BEGIN
    DELETE FROM Directors WHERE director_id = p_director_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteRatingById` (IN `p_rating_id` INT, IN `p_user_id` INT)   BEGIN
    DECLARE rating_count INT;

    SELECT COUNT(*) INTO rating_count FROM ratings 
    WHERE rating_id = p_rating_id AND user_id = p_user_id;

    IF rating_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rating not found or you do not have permission to delete this rating.';
    ELSE
        DELETE FROM ratings WHERE rating_id = p_rating_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteUser` (IN `p_user_id` INT)   BEGIN
    DECLARE user_exists INT;
    
    SELECT COUNT(*) INTO user_exists FROM users WHERE user_id = p_user_id;
    
    IF user_exists > 0 THEN
        DELETE FROM users WHERE user_id = p_user_id;
        SELECT CONCAT('User with ID ', p_user_id, ' deleted successfully') AS message;
    ELSE
        SELECT CONCAT('User with ID ', p_user_id, ' not found') AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteUserFavorite` (IN `p_user_id` INT, IN `p_movie_id` INT, OUT `p_result` INT)   BEGIN
    DECLARE v_count INT;
    
    -- Ellenőrizzük, hogy létezik-e a rekord
    SELECT COUNT(*) INTO v_count 
    FROM user_favorites 
    WHERE user_id = p_user_id AND movie_id = p_movie_id;
    
    IF v_count = 0 THEN
        SET p_result = 0; -- Nem található rekord
    ELSE
        -- Törlés végrehajtása
        DELETE FROM user_favorites 
        WHERE user_id = p_user_id AND movie_id = p_movie_id;
        
        SET p_result = 1; -- Sikeres törlés
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `everyActorInAMovie` ()   SELECT movie_id, COUNT(*) AS actor_count
FROM movie_actors
GROUP BY movie_id
ORDER BY actor_count DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `filmDetails` ()   SELECT 
    movie_id, 
    movie_name, 
    release_year, 
    description, 
    (SELECT name FROM directors WHERE director_id = movies.director_id) AS director_name, 
    (SELECT name FROM genres WHERE genre_id = movies.genre_id) AS genre_name
FROM movies$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `genreNames` ()   select name
from genres$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActorById` (IN `p_actor_id` INT)   BEGIN
    SELECT * FROM actors WHERE actor_id = p_actor_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActorsByMovie` (IN `p_movie_id` INT)   BEGIN
    SELECT 
        a.actor_id,
        a.name,
        a.birth_date,
        a.actor_image
    FROM 
        actors a
    INNER JOIN 
        movie_actors ma ON a.actor_id = ma.actor_id
    WHERE 
        ma.movie_id = p_movie_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActors` ()   BEGIN
    SELECT * FROM actors;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllDirectors` ()   BEGIN
    SELECT * FROM Directors;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllMoviesDetails` ()   BEGIN
    SELECT 
        m.movie_id,
        m.movie_name,
        m.release_year,
        m.description,
        GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ', ') AS genres,
        GROUP_CONCAT(DISTINCT d.name ORDER BY d.name SEPARATOR ', ') AS directors,
        GROUP_CONCAT(DISTINCT a.name ORDER BY a.name SEPARATOR ', ') AS actors
    FROM movies m
    LEFT JOIN movie_genres mg ON m.movie_id = mg.movie_id
    LEFT JOIN genres g ON mg.genre_id = g.genre_id
    LEFT JOIN movie_directors md ON m.movie_id = md.movie_id
    LEFT JOIN directors d ON md.director_id = d.director_id
    LEFT JOIN movie_actors ma ON m.movie_id = ma.movie_id
    LEFT JOIN actors a ON ma.actor_id = a.actor_id
    GROUP BY m.movie_id, m.movie_name, m.release_year, m.description;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllRatings` ()   BEGIN
    SELECT 
        r.rating_id,
        u.username AS reviewer,
        m.movie_name,
        r.rating,
        r.review,
        r.rating_date
    FROM ratings r
    JOIN users u ON r.user_id = u.user_id
    JOIN movies m ON r.movie_id = m.movie_id
    ORDER BY r.rating_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllUsers` ()   BEGIN
    SELECT * FROM users;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDirectorById` (IN `p_director_id` INT)   BEGIN
    SELECT * FROM Directors WHERE director_id = p_director_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDirectorsByMovie` (IN `p_movie_id` INT)   BEGIN
    SELECT 
        d.director_id,
        d.name AS director_name,
        d.birth_date,
        d.director_image
    FROM 
        directors d
    INNER JOIN 
        movie_directors md ON d.director_id = md.director_id
    WHERE 
        md.movie_id = p_movie_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getMoviesByActor` (IN `actor_name` VARCHAR(255))   BEGIN
    SELECT m.movie_name, m.release_year
    FROM movies m
    JOIN movie_actors ma ON m.movie_id = ma.movie_id
    JOIN actors a ON ma.actor_id = a.actor_id
    WHERE a.name LIKE CONCAT('%', actor_name, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMoviesByAverageRating` (IN `p_rating_value` DECIMAL(3,1))   BEGIN
    SELECT 
        m.movie_id,
        m.movie_name AS title,
        m.cover,
        ROUND(AVG(r.rating), 1) AS average_rating,
        COUNT(r.rating_id) AS rating_count
    FROM 
        movies m
    LEFT JOIN 
        ratings r ON m.movie_id = r.movie_id
    GROUP BY 
        m.movie_id, m.movie_name, m.cover
    HAVING 
        ROUND(AVG(r.rating), 1) = p_rating_value
    ORDER BY 
        average_rating DESC, rating_count DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMoviesByGenre` (IN `genre_name` VARCHAR(255))   BEGIN
    SELECT m.movie_id, m.movie_name, g.name
    FROM movies m
    JOIN movie_genres mg ON m.movie_id = mg.movie_id
    JOIN genres g ON mg.genre_id = g.genre_id
    WHERE g.name LIKE genre_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMoviesByGenreId` (IN `p_genre_id` INT)   BEGIN
    SELECT 
        m.movie_id,
        m.movie_name AS title,
        m.cover,
        m.release_year,
        g.name
    FROM 
        movies m
    JOIN 
        movie_genres mg ON m.movie_id = mg.movie_id
    JOIN 
        genres g ON mg.genre_id = g.genre_id
    WHERE 
        g.genre_id = p_genre_id
    ORDER BY 
        m.movie_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMoviesByRoundedRating` (IN `p_rounded_rating` INT)   BEGIN
    SELECT 
        m.movie_id,
        m.movie_name AS title,
        m.cover,
        ROUND(AVG(r.rating), 1) AS exact_average,
        COUNT(r.rating_id) AS rating_count
    FROM 
        movies m
    LEFT JOIN 
        ratings r ON m.movie_id = r.movie_id
    GROUP BY 
        m.movie_id, m.movie_name, m.cover
    HAVING 
        ROUND(AVG(r.rating)) = p_rounded_rating
    ORDER BY 
        exact_average DESC, rating_count DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRandomMovies` (IN `p_count` INT)   BEGIN
    SELECT 
        movie_id AS movieId,
        movie_name AS title,
        cover
    FROM 
        movies
    ORDER BY 
        RAND()
    LIMIT 
        p_count;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRatingsByMovie` (IN `movie_title` VARCHAR(255))   BEGIN
    SELECT 
        r.rating_id,
        u.username AS reviewer,
        r.rating,
        r.review,
        r.rating_date
    FROM ratings r
    JOIN users u ON r.user_id = u.user_id
    JOIN movies m ON r.movie_id = m.movie_id
    WHERE m.movie_name = movie_title
    ORDER BY r.rating_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserFavorites` (IN `userId` INT)   BEGIN
    SELECT m.movie_id, m.movie_name, m.release_year, m.cover
    FROM user_favorites uf 
    JOIN movies m ON uf.movie_id = m.movie_id 
    WHERE uf.user_id = userId
    ORDER BY uf.added_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserRatings` (IN `p_user_id` INT)   BEGIN
    SELECT 
        r.rating_id,
        r.rating,
        r.review,
        r.rating_date,
        m.movie_id,
        m.movie_name AS title,  -- Using AS to match your Java code's expectation
        m.release_year,
        m.cover
    FROM 
        ratings r
    JOIN 
        movies m ON r.movie_id = m.movie_id
    WHERE 
        r.user_id = p_user_id  -- Using the parameter name defined in the procedure
    ORDER BY 
        r.rating_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `emailIN` VARCHAR(255), IN `passwordIN` VARCHAR(255))   BEGIN
    SELECT * FROM users WHERE email = emailIN AND password = passwordIN;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `movieTitles` ()   SELECT movie_name
FROM movies$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `register_user` (IN `p_username` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255))   BEGIN
    INSERT INTO users (username, email, password, registration_date, role)
    VALUES (p_username, p_email, p_password, CURDATE(), 'user');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchUsersByName` (IN `search_term` VARCHAR(255))   BEGIN
    SELECT user_id, username, email, registration_date, role
    FROM users
    WHERE username LIKE CONCAT('%', search_term, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateActor` (IN `p_actor_id` INT, IN `p_name` VARCHAR(255), IN `p_birth_date` DATE, IN `p_actor_image` VARCHAR(255))   BEGIN
    SET @current_name = (SELECT name FROM actors WHERE actor_id = p_actor_id);
    SET @current_birth = (SELECT birth_date FROM actors WHERE actor_id = p_actor_id);
    SET @current_image = (SELECT actor_image FROM actors WHERE actor_id = p_actor_id);
    
    UPDATE actors
    SET 
        name = IF(p_name IS NULL, @current_name, p_name),
        birth_date = IF(p_birth_date IS NULL, @current_birth, p_birth_date),
        actor_image = IF(p_actor_image IS NULL, @current_image, p_actor_image)
    WHERE actor_id = p_actor_id;
    
    SELECT * FROM actors WHERE actor_id = p_actor_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDirector` (IN `p_director_id` INT, IN `p_name` VARCHAR(100), IN `p_director_image` VARCHAR(255), IN `p_birth_date` DATE)   BEGIN
    UPDATE Directors
    SET name = p_name,
        director_image = p_director_image,
        birth_date = p_birth_date
    WHERE director_id = p_director_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUser` (IN `p_user_id` INT, IN `p_username` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_role` VARCHAR(5))   BEGIN
    UPDATE users
    SET 
        username = COALESCE(p_username, username),
        email = COALESCE(p_email, email),
        password = COALESCE(p_password, password),
        role = COALESCE(p_role, role)
    WHERE user_id = p_user_id;
    
    SELECT * FROM users WHERE user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_username` (IN `p_user_id` INT, IN `p_current_password` VARCHAR(255), IN `p_new_username` VARCHAR(255), OUT `p_result` VARCHAR(255))   BEGIN
    -- Változók deklarálása DEFAULT értékkel
    DECLARE v_user_exists INT DEFAULT 0;
    DECLARE v_password_match INT DEFAULT 0;
    DECLARE v_username_taken INT DEFAULT 0;
    
    -- 1. Felhasználó létezésének ellenőrzése
    SELECT COUNT(*) INTO v_user_exists 
    FROM users 
    WHERE user_id = p_user_id;
    
    -- 2. Eredmény kezelése
    IF v_user_exists = 0 THEN
        SET p_result = 'ERROR: User not found';
    ELSE
        -- 3. Jelszó ellenőrzése (egyszerű változat)
        SELECT COUNT(*) INTO v_password_match 
        FROM users 
        WHERE user_id = p_user_id 
        AND password = p_current_password;
        
        IF v_password_match = 0 THEN
            SET p_result = 'ERROR: Incorrect password';
        ELSE
            -- 4. Felhasználónév foglaltság ellenőrzése
            SELECT COUNT(*) INTO v_username_taken 
            FROM users 
            WHERE username = p_new_username 
            AND user_id != p_user_id;
            
            IF v_username_taken > 0 THEN
                SET p_result = 'ERROR: Username already taken';
            ELSE
                -- 5. Sikeres frissítés
                UPDATE users 
                SET username = p_new_username 
                WHERE user_id = p_user_id;
                
                SET p_result = 'SUCCESS: Username updated';
            END IF;
        END IF;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `actors`
--

CREATE TABLE `actors` (
  `actor_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `actor_image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `actors`
--

INSERT INTO `actors` (`actor_id`, `name`, `birth_date`, `actor_image`) VALUES
(1, 'Sinkovits Imre', '1928-09-21', 'sinkovits_imre.jpg'),
(2, 'Bánsági Ildikó', '1947-06-19', 'bansagi_ildiko.jpg'),
(3, 'Kállai Ferenc', '1925-07-04', 'kallai_ferenc.jpg'),
(4, 'Bodrogi Gyula', '1934-04-15', 'bodrogi_gyula.jpg'),
(5, 'Darvas Iván', '1925-06-14', 'darvas_ivan.jpg'),
(6, 'Mikó István', '1947-11-24', 'miko_istvan.jpg'),
(7, 'Cserhalmi György', '1948-02-17', 'cserhalmi_gyorgy.jpg'),
(8, 'Latinovits Zoltán', '1931-09-09', 'latinovits_zoltan.jpg'),
(9, 'Hernádi Judit', '1956-04-11', 'hernadi_judit.jpg'),
(10, 'Kovács Kati', '1944-10-25', 'kovacs_kati.jpg'),
(11, 'Kabos Gyula', '1887-03-19', 'kabos_gyula.jpg'),
(12, 'Béres Ilona', '1942-06-04', 'beres_ilona.jpg'),
(13, 'Balsai Móni', '1977-12-13', 'balsai_moni.jpg'),
(14, 'Csányi Sándor', '1975-12-19', 'csanyi_sandor.jpg'),
(15, 'Trill Zsolt', '1971-03-22', 'trill_zsolt.jpg'),
(16, 'Czapkó Antal', '1978-05-06', 'czapko_antal.jpg'),
(17, 'Pogány Judit', '1944-07-10', 'pogany_judit.jpg'),
(18, 'Garas Dezső', '1934-12-09', 'garas_dezso.jpg'),
(19, 'Törőcsik Mari', '1935-11-23', 'torocsik_mari.jpg'),
(20, 'Nagy Zsolt', '1974-10-28', 'nagy_zsolt.jpg'),
(21, 'Gera Marina', '1984-07-17', 'gera_marina.jpg'),
(22, 'Dobó Kata', '1974-02-25', 'dobo_kata.jpg'),
(23, 'Eperjes Károly', '1954-02-17', 'eperjes_karoly.jpg'),
(24, 'Eszenyi Enikő', '1961-01-11', 'eszenyi_eniko.jpg'),
(25, 'Rudolf Péter', '1959-10-15', 'rudolf_peter.jpg'),
(26, 'Morcsányi Géza', '1952-09-28', 'morcsanyi_geza.jpg'),
(27, 'Nagy Marcell', '2004-03-11', 'nagy_marcell.jpg'),
(28, 'Jászai Mari', '1850-02-24', 'jaszai_mari.jpg'),
(29, 'Koltai Róbert', '1943-12-16', 'koltai_robert.jpg'),
(30, 'Somlay Artúr', '1883-02-28', 'somlay_artur.jpg'),
(31, 'Gábor Miklós', '1919-04-07', 'gabor_miklos.jpg'),
(32, 'Bánky Zsuzsa', '1921-10-19', 'banky_zsuzsa.jpg'),
(33, 'Rónay Ábrahám', '1931-01-01', 'ronay_abraham.jpg'),
(34, 'Bárdy György', '1921-05-26', 'bardy_gyorgy.jpg'),
(35, 'Rozsos István', '1930-06-10', 'rozsos_istvan.jpg'),
(36, 'Klaus Maria Brandauer', '1943-06-22', 'klaus_maria_brandauer.jpg'),
(37, 'Krystyna Janda', '1952-12-18', 'krystyna_janda.jpg'),
(38, 'Rolf Hoppe', '1930-12-06', 'rolf_hoppe.jpg'),
(39, 'Both Béla', '1912-06-01', 'both_bela.jpg'),
(40, 'Őze Lajos', '1935-04-27', 'oze_lajos.jpg'),
(41, 'Major Tamás', '1910-01-26', 'major_tamas.jpg'),
(42, 'Márkus László', '1927-06-10', 'markus_laszlo.jpg'),
(43, 'Darvas Lili', '1902-04-10', 'darvas_lili.jpg'),
(44, 'Schuster Lóránt', '1950-07-20', 'schuster_lorant.jpg'),
(45, 'Földes László (Hobo)', '1945-02-13', 'foldes_laszlo_hobo.jpg'),
(46, 'Deák Bill Gyula', '1948-11-08', 'deak_bill_gyula.jpg'),
(47, 'Póka Egon', '1953-06-19', 'poka_egon.jpg'),
(48, 'Venczel Vera', '1946-03-10', 'venczel_vera.jpg'),
(49, 'Kovács István', '1944-06-27', 'kovacs_istvan.jpg'),
(50, 'Horváth Sándor', '1941-06-14', 'horvath_sandor.jpg'),
(51, 'Bencze Ferenc', '1912-07-04', 'bencze_ferenc.jpg'),
(52, 'Jácint Juhász', '1944-11-28', 'jacint_juhasz.jpg'),
(53, 'Kozák András', '1943-02-23', 'kozak_andras.jpg'),
(54, 'Olvasztó Imre', '1967-01-01', 'olvaszto_imre.jpg'),
(55, 'Haumann Péter', '1941-05-17', 'haumann_peter.jpg'),
(56, 'Horváth Teri', '1925-08-27', 'horvath_teri.jpg'),
(57, 'Pécsi Ildikó', '1940-05-21', 'pecsi_ildiko.jpg'),
(58, 'Csortos Gyula', '1883-03-08', 'csortos_gyula.jpg'),
(59, 'Oleg Jankovszkij', '1944-02-23', 'Oleg.jpg'),
(60, 'Andorai Péter', '1948-04-25', 'andorai.jpg'),
(61, 'Máté Gábor', '1955-04-29', 'mate.jpg'),
(68, 'Bede-Fazekas Szabolcs', '1966-10-22', 'bede.jpg'),
(69, 'Schmied Zoltán', '1975-12-15', 'schmied.jpg'),
(75, 'Balla Eszter', '1980-05-11', 'balla.jpg'),
(76, 'Mucsi Zoltán', '1957-09-09', 'mucsi.jpg'),
(77, 'Czene Csaba', '1960-01-01', 'czene.jpg'),
(78, 'Trócsányi Gergely', '1974-03-02', 'trocsa.jpg'),
(79, 'Molnár Piroska', '1945-10-01', 'piroksa.jpg'),
(80, 'Kaszás Attila', '1960-03-16', 'kaszas.jpg'),
(81, 'Ónodi Eszter', '1973-02-17', 'onodi.jpg'),
(82, 'Bálint András', '1943-04-26', 'balnint.jpg'),
(83, 'Anthony kemp', '1954-11-03', 'antoan.jpg'),
(84, 'William Burleigh', '1952-01-01', 'willi.jpg'),
(85, 'Julian Holdaway', '1950-01-01', 'julian.jpg'),
(86, 'Karalyos Gábor', '1980-01-25', 'karaly.jpg'),
(87, 'Fenyő Iván', '1979-06-15', 'fenyo.jpg'),
(88, 'Szávai Viktória', '1976-05-17', 'sawa.jpg'),
(89, 'Pap Vera', '1956-01-27', 'pap.jpg'),
(90, 'Gáspár Sándor', '1956-04-09', 'gaspar.jpg'),
(91, 'Lukáts Andor', '1943-03-11', 'lukats.jpg'),
(92, 'Bogusław Linda', '1952-06-27', 'bogu.jpg'),
(93, 'Méhes Marietta', '1958-06-17', 'émhes.jph'),
(94, 'Gesztesi Károly', '1963-04-16', 'geszte.jph'),
(95, 'Gyuriska János', '1972-12-07', 'gyugyu.jpg'),
(96, 'Seress Zoltán', '1962-05-21', 'sörike.jpg'),
(97, 'Borbély Alexandra', '1986-09-04', 'borbála.jpg'),
(98, 'Schneider Zoltán', '1970-02-05', 'wesleysneijder.jpg'),
(99, 'Nagy Ervin', '1976-09-25', 'nagyxd.jpg'),
(100, 'Tenki Réka', '1986-06-18', 'tank.jpg'),
(101, 'Psotta Zsófia', '1997-05-03', 'pot.jpg'),
(102, 'Zsótér Sándor', '1961-06-20', 'zsoter.jpg'),
(103, 'Horváth Lili', '1976-06-18', 'horvath.jpg'),
(104, 'Csorba András', '1927-08-25', 'csorba.jpg'),
(105, 'Krencsey Marianne', '1931-07-09', 'krencsey.jpg'),
(106, 'Gobbi Hilda', '1913-06-06', 'goblin.jpg'),
(107, 'Szabados Mihály', '1972-01-24', 'szabad.jpg'),
(108, 'Ulrich Matthes', '1959-05-09', 'dia.jpg'),
(109, 'Ulrich Thomsen', '1963-12-06', 'dia2.jpg'),
(110, 'Bognár Gyöngyvér', '1972-01-31', 'gyöngyvér.jpg'),
(111, 'Ferenczik Áron', NULL, 'ferencem.jpg'),
(112, 'Röhrig Géza', '1967-05-11', 'rohog.jpg'),
(113, 'Molnár Levente', '1976-03-10', 'lokomotiv.jpg'),
(114, 'Lars Rudolph', '1966-08-18', 'larsson.jpg'),
(115, 'Peter Fitz', '1950-04-28', 'fitz.jpg'),
(116, 'Hanna Schygula', '1943-12-25', 'schsch.jpg'),
(117, 'Tarr Béla', '1955-06-21', 'tarr.jpg'),
(118, 'Krasznahorkai László', '1954-01-05', 'laci.jpg'),
(119, 'Hajduk Károly', '1979-01-27', 'hakjduk.jpg'),
(120, 'Anger Zsolt', '1969-05-04', 'angerer.jpg'),
(121, 'Szabó Éva', '1943-06-04', 'szaboeva.jpg'),
(122, 'Pásztor Erzsi', '1936-09-24', 'paztor.jpg'),
(123, 'Dunai Tamás', '1949-07-10', 'duna.jpg'),
(124, 'Horváth László', '1943-02-10', 'horvat.jpg'),
(125, 'Jankovics Péter', '1978-11-16', 'kanko'),
(126, 'Kovács Zsolt', '1951-07-20', 'kova'),
(127, 'Trokán Nóra', '1986-08-13', 'trokan'),
(128, 'Kurta Niké', '1989-06-07', 'kurtakinte'),
(129, 'Martina Gedeck', '1961-09-14', 'martini.jpg'),
(130, 'Helen Mirren', '1945-07-26', 'helena.jpg'),
(131, 'Blaskó Péter', '1948-06-13', 'blasko.jpg'),
(132, 'Fodor Tamás', '1942-09-03', 'fodor.jpg'),
(133, 'Juhász István', '1978-12-20', 'isti.jpg'),
(134, 'Tilda Swinton', '1960-11-05', 'Swansea.jpg'),
(135, 'Derzsi János', '1954-04-20', 'derzse.jpg'),
(136, 'Szirtes Ági', '1955-09-21', 'sirt.jpg'),
(137, 'Pauer Gyula', '1941-02-28', 'paula.jpg'),
(138, 'Dráfi Mátyás', '1942-11-17', 'drago.jpg'),
(139, 'Mokos Attila', '1964-12-13', 'mokás.jpg'),
(140, 'Benkő Géza', '1969-10-28', 'benko.jpg'),
(141, 'Bán János', '1955-10-04', 'banbalazs.jpg'),
(142, 'Marián Labuda', '1944-10-28', 'labda'),
(143, 'Libuše Šafránková', '1953-07-07', 'lubus'),
(144, 'Halász Péter', '1943-03-09', 'halas.jpgh'),
(145, 'Nagy Mari', '1961-05-09', 'nagyi.jpg'),
(146, 'László Zsolt', '1965-10-31', 'laszla.jpg'),
(147, 'Hámori Gabriella', '1978-11-01', 'gaboca'),
(148, 'Kulka János', '1958-11-11', 'kuka'),
(149, 'Hajdu Miklós', NULL, 'miki'),
(150, 'Ötvös András', '1984-05-03', 'ötös'),
(151, 'Rába Roland', '1974-11-04', 'éábna'),
(152, 'Keresztes Tamás', '1978-03-24', 'kereszte'),
(153, 'Szabó Kimmel Tamás', '1984-10-09', 'kim'),
(154, 'Kerekes Vica', '1981-03-28', 'ezmikerek'),
(155, 'Gyabronka József', '1953-05-14', 'abroncs');

-- --------------------------------------------------------

--
-- Table structure for table `directors`
--

CREATE TABLE `directors` (
  `director_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `director_image` varchar(255) DEFAULT NULL,
  `birth_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `directors`
--

INSERT INTO `directors` (`director_id`, `name`, `director_image`, `birth_date`) VALUES
(1, 'Radványi Géza', 'radvanyi_geza.jpg', '1907-09-26'),
(2, 'Szabó István', 'szabo_istvan.jpg', '1938-02-18'),
(3, 'Bacsó Péter', 'bacso_peter.jpg', '1928-01-06'),
(4, 'Keleti Márton', 'keleti_marton.jpg', '1905-04-27'),
(5, 'Makk Károly', 'makk_karoly.jpg', '1925-12-22'),
(6, 'Ternovszky Béla', 'ternovszky_bela.jpg', '1943-05-23'),
(7, 'Szomjas György', 'szomjas_gyorgy.jpg', '1940-11-26'),
(8, 'Várkonyi Zoltán', 'varkonyi_zoltan.jpg', '1912-05-13'),
(9, 'Fábri Zoltán', 'fabri_zoltan.jpg', '1917-10-15'),
(10, 'Jancsó Miklós', 'jancso_miklos.jpg', '1921-09-27'),
(11, 'Mihályfi Imre', 'mihalyfi_imre.jpg', '1912-12-06'),
(12, 'Sándor Pál', 'sandor_pal.jpg', '1939-04-19'),
(13, 'Enyedi Ildikó', 'enyedi_ildiko.jpg', '1955-11-15'),
(14, 'Ujj Mészáros Károly', 'ujj_meszaros_karoly.jpg', '1973-08-21'),
(15, 'Nimród Antal', 'nimrod_antal.jpg', '1973-11-30'),
(16, 'Pálfi György', 'palfi_gyorgy.jpg', '1974-04-19'),
(17, 'Bereményi Géza', 'beremenyi_geza.jpg', '1946-01-25'),
(18, 'Gyöngyössy Imre', 'gyongyossy_imre.jpg', '1930-02-25'),
(19, 'Szőts István', 'szots_istvan.jpg', '1912-06-30'),
(20, 'Török Ferenc', 'torok_ferenc.jpg', '1971-04-23'),
(21, 'Gothár Péter', 'gothar_peter.jpg', '1947-08-28'),
(22, 'Sopsits Árpád', 'sopsits_arpad.jpg', '1952-02-02'),
(23, 'Fekete Ibolya', 'fekete_ibolya.jpg', '1951-01-28'),
(24, 'Mundruczó Kornél', 'mundruczo_kornel.jpg', '1975-04-03'),
(25, 'Hajdu Szabolcs', 'hajdu_szabolcs.jpg', '1972-04-26'),
(26, 'Magyar Dezső', 'magyar_dezso.jpg', '1934-12-04'),
(27, 'Herskó János', 'hersko_janos.jpg', '1926-04-09'),
(28, 'Marton Endre', 'marton_endre.jpg', '1915-09-20'),
(29, 'Fehér György', 'feher_gyorgy.jpg', '1939-12-15'),
(30, 'Kertész Mihály', 'kertesz_mihaly.jpg', '1886-12-24'),
(31, 'Szász Attila', 'szasz_attila.jpg', '1972-10-23'),
(32, 'Goda Krisztina', 'goda_krisztina.jpg', '1970-03-28'),
(33, 'Tímár Péter', 'timar_peter.jpg', '1950-12-19'),
(34, 'Xantus János', 'xantus_janos.jpg', '1953-11-07'),
(35, 'Herendi Gábor', 'herendi_gabor.jpg', '1960-12-02'),
(36, 'Mundruczkó Kornél', 'mundruczko_kornel.jpg', '1975-04-03'),
(37, 'Korda Sándor', 'korda_sandor.jpg', '1893-09-16'),
(38, 'Koltai Róbert', 'koltai_robert.jpg', '1943-12-16'),
(39, 'Mihályfy Sándor', 'mihalyfy_sandor.jpg', '1937-01-21'),
(40, 'Székely István', 'szekely_istvan.jpg', '1899-02-25'),
(41, 'Szász János', 'szasz_janos.jpg', '1958-03-14'),
(42, 'Reisz Gábor', 'reisz_gabor.jpg', '1980-01-19'),
(43, 'Nemes Jeles László', 'nemes_jeles_laszlo.jpg', '1977-02-18'),
(44, 'Tarr Béla', 'tarr_bela.jpg', '1955-07-21'),
(47, 'Gigor Attila', 'gigor_attila.jpg', '1978-04-05'),
(48, 'Gábor Pál', 'gabor_pal.jpg', '1932-11-02'),
(49, 'Bergendy Péter', 'bergendy_peter.jpg', '1969-04-04'),
(50, 'Hajdu Szabolcs', 'hajdu_szabolcs.jpg', '1972-04-26'),
(51, 'Jiří Menzel', 'jiri_menzel.jpg', '1938-02-23'),
(52, 'Bodzsár Márk', 'bodzsar_mark.jpg', '1983-06-16'),
(53, 'Szabó Virág', 'szabo_virag.jpg', '1985-10-04');

-- --------------------------------------------------------

--
-- Table structure for table `genres`
--

CREATE TABLE `genres` (
  `genre_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `genres`
--

INSERT INTO `genres` (`genre_id`, `name`) VALUES
(1, 'Dráma'),
(2, 'Szatíra'),
(3, 'Vígjáték'),
(4, 'Animációs vígjáték'),
(5, 'Zenei'),
(6, 'Történelmi'),
(7, 'Ifjúsági'),
(8, 'Sci-fi'),
(9, 'Sci-fi'),
(10, 'Horror'),
(11, 'Thriller'),
(12, 'Kaland'),
(13, 'Fantasztikus'),
(14, 'Dokumentumfilm'),
(15, 'Romantikus dráma'),
(16, 'vígjáték-dráma horror'),
(17, 'vígjáték-dráma'),
(18, 'művészfilm'),
(19, 'Háborús'),
(20, 'Politikai vígjáték'),
(21, 'Krimi'),
(22, 'Western');

-- --------------------------------------------------------

--
-- Table structure for table `movies`
--

CREATE TABLE `movies` (
  `movie_id` int(11) NOT NULL,
  `release_year` int(11) DEFAULT NULL,
  `description` text,
  `movie_name` varchar(99) NOT NULL,
  `Length` int(11) DEFAULT NULL,
  `cover` varchar(255) DEFAULT NULL,
  `trailer_link` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `movies`
--

INSERT INTO `movies` (`movie_id`, `release_year`, `description`, `movie_name`, `Length`, `cover`, `trailer_link`) VALUES
(101, 1948, 'Egy háború utáni történet gyermekekről, akik a túlélésért küzdenek.', 'Valahol Európában', 100, 'https://m.blog.hu/36/365nap365film/image/valahol_europaban_02_1.jpg', 'https://www.youtube.com/watch?v=gwhE9A6Pzso'),
(102, 1981, 'Egy színész, aki kompromisszumokat köt a karrierjéért.', 'Mephisto', 144, NULL, 'https://www.youtube.com/watch?v=EbpCuStwXz4'),
(103, 1969, 'Egy férfi szürreális tapasztalatai a kommunista rezsim alatt.', 'A tanú', 110, NULL, 'https://www.youtube.com/watch?v=B696W2Gwvmk'),
(104, 1965, 'Egy katona humoros kalandjai a második világháború alatt.', 'Tizedes meg a többiek', 109, NULL, 'https://www.youtube.com/watch?v=8bhb4eeJB7o'),
(105, 1971, 'Egy szerelmi történet a politikai elnyomás árnyékában.', 'Szerelem', 96, NULL, 'https://www.youtube.com/watch?v=lgkicEevbSA'),
(106, 1986, 'Egy humoros animációs történet a macskák és egerek harcáról.', 'Macskafogó', 96, NULL, 'https://www.youtube.com/watch?v=6WJxaSfAFXY'),
(107, 1981, 'Egy zenekar tagjainak küzdelmei a rendszer ellen.', 'Kopaszkutya', 98, NULL, 'https://www.youtube.com/watch?v=RVRiEwmwNd8'),
(108, 1968, 'A magyar történelem egyik legnagyobb csatája.', 'Egri csillagok', 120, NULL, 'https://www.youtube.com/watch?v=04CZI0A0Vgw'),
(109, 1976, 'Egy filozófiai dráma az emberi erkölcsről.', 'Az ötödik pecsét', 102, NULL, 'https://www.youtube.com/watch?v=d8STQElOASA'),
(110, 1967, 'Egy csoport katona története az orosz forradalom idején.', 'Csillagosok, katonák', 94, NULL, 'https://www.youtube.com/watch?v=xTnJ74KeTfs'),
(111, 1979, 'Egy humoros történet egy falusi bakter életéről.', 'Indul a bakterház', 85, 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.imdb.com%2Ftitle%2Ftt0121403%2Ffullcredits%2F&psig=AOvVaw38t8lwuU3IiFDT1T3gyLTd&ust=1744485344328000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCPDSobvY0IwDFQAAAAAdAAAAABAI', 'https://www.youtube.com/watch?v=tH6uX1_1_yg'),
(112, 1931, 'Egy újgazdag család és az elegáns lakáj története.', 'Hyppolit, a lakáj', 90, NULL, 'https://www.youtube.com/watch?v=nw4ch5oG3fg'),
(113, 1989, 'Két nővérek élete a 20. század elején.', 'Az én XX. századom', 95, NULL, 'https://www.youtube.com/watch?v=CCdXnsxON_A'),
(114, 2015, 'Egy fiatal nő szerelmi története, némi misztikummal.', 'Liza, a rókatündér', 95, NULL, 'https://www.youtube.com/watch?v=N1gQ3eZCH8w'),
(115, 2003, 'Egy metróellenőr mindennapjai és kihívásai.', 'Kontroll', 105, NULL, 'https://www.youtube.com/watch?v=qultfnaMP50'),
(116, 2006, 'Egy szürreális családi történet több generáción keresztül.', 'Taxidermia', 91, NULL, 'https://www.youtube.com/watch?v=xeQqwG3D0l4'),
(117, 2002, 'Széchenyi István életének drámai ábrázolása.', 'Hídember', 100, NULL, 'https://www.youtube.com/watch?v=JB-UW1oLl6A'),
(118, 2002, 'Egy falusi közösség csendes története a mindennapokról.', 'Hukkle', 75, NULL, 'https://www.youtube.com/watch?v=o-n6exBvK3E'),
(119, 1966, 'Egy fiú és az apja kapcsolata a múlt árnyékában.', 'Apa', 90, NULL, 'https://www.youtube.com/watch?v=wNmcEAeV3OM'),
(120, 1969, 'Egy fiúcsapat barátságának története.', 'Pál utcai fiúk', 95, NULL, 'https://www.youtube.com/watch?v=cyuWNiQBpZs'),
(121, 2001, 'A rendszerváltás idején játszódó fiatalos történet.', 'Moszkva tér', 101, NULL, 'https://www.youtube.com/watch?v=yIQmwb9pgiI'),
(122, 2018, 'Egy nő túlélési története egy szovjet munkatáborban.', 'Örök tél', 98, NULL, 'https://www.youtube.com/watch?v=HZSTvEVz87I'),
(123, 2006, 'Az 1956-os forradalom története és annak hatásai.', 'Szabadság, szerelem', 103, 'https://m.media-amazon.com/images/M/MV5BOGQxNzZiNzAtZDA3YS00NDU5LWExOTgtYWY4YzU5ZDlmNTA0XkEyXkFqcGc@._V1_.jpg', 'https://www.youtube.com/watch?v=k3NIwJEzdyY'),
(124, 1991, 'Egy humoros történet a rendszerváltás idejéről.', 'Csapd le csacsi!', 95, NULL, 'https://www.youtube.com/watch?v=HXh4TNoLyF4'),
(125, 1984, 'Egy szürreális szerelmi történet.', 'Eszkimó asszony fázik', 92, NULL, 'https://www.youtube.com/watch?v=-ENx0weqhhk'),
(126, 2004, 'Egy humoros történet a magyar történelem jelentős eseményeiről.', 'Magyar vándor', 116, NULL, 'https://www.youtube.com/watch?v=HEMHUpUzeFY'),
(127, 2017, 'Két lélek különös kapcsolata egy vágóhídon.', 'Testről és lélekről', 116, NULL, 'https://www.youtube.com/watch?v=pnYts52GaiA'),
(128, 2014, 'Egy kóbor kutya története a modern társadalomban.', 'Fehér isten', 119, NULL, 'https://www.youtube.com/watch?v=seflzYctPI8'),
(129, 1918, 'Egy klasszikus Jókai Mór regény adaptációja.', 'Aranyember', 98, NULL, NULL),
(130, 1993, 'Egy humoros és nosztalgikus történet az életről.', 'Sose halunk meg', 107, 'https://m.media-amazon.com/images/M/MV5BNjEwYmJiYTYtYzMxMS00NGFmLWFjNTMtZTU5ZjUwMDI1NTdhXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg', 'https://www.youtube.com/watch?v=rJsGF1nOmRY'),
(131, 2013, 'A film középpontjában álló ikerpárt édesanyjuk egy határszéli faluba küldi nagymamájukhoz, hogy ott vészeljék át a háború végét.', 'A Nagy Füzet', 109, NULL, 'https://www.youtube.com/watch?v=4MLJ09XmugA'),
(132, 2014, 'Szentesi Áron egy 20-as évei végén járó budapesti fiú, aki munkanélküliként éli mindennapjait, de az egyik nap barátnője, Eszter elhagyja.', 'VAN valami furcsa és megmagyarázhatatlan', 90, NULL, 'https://www.youtube.com/watch?v=rbyOcZHGjZc'),
(133, 2015, '1944. október 7-8-án játszódik Auschwitz-Birkenauban a Sonderkommandók lázadása idején.', 'Saul fia', 107, NULL, 'https://www.youtube.com/watch?v=5V5TZkFa5AM'),
(134, 2000, 'Egy kisváros lakóit egy vándorcirkusz tartja félelemben.', 'Werckmeister harmóniák', 145, NULL, 'https://www.youtube.com/watch?v=-tJVdq_G_Go'),
(135, 2011, 'Egy öreg paraszt és lánya monoton, sötét hétköznapjait követjük.', 'A torinói ló', 146, NULL, 'https://www.youtube.com/watch?v=zk41BR72csI'),
(136, 2016, 'Egy sorozatgyilkos tartja rettegésben az 1950-es évek végének Magyarországát.', 'A martfűi rém', 121, NULL, 'https://www.youtube.com/watch?v=HIYxv_aQH_0'),
(137, 1978, 'Egy fiatal ápolónő szembesül a rendszer manipulációjával és saját erkölcsi dilemmáival.', 'Angi Vera', 96, NULL, 'https://www.youtube.com/watch?v=y6Xt3f2Mg48'),
(138, 2016, 'Egy benzinkútnál összetalálkozik egy öreg benzinkutas és egy fiatal fiú egy veszélyes helyzettel.', 'Kút', 95, NULL, 'https://www.youtube.com/watch?v=lwGQ6yr7rns'),
(139, 2012, 'Egy írónő és a házvezetőnője közötti titokzatos kapcsolat története.', 'Az ajtó', 98, NULL, 'https://www.youtube.com/watch?v=c_45YrzoO9A'),
(140, 2008, 'Egy patológus egy gyilkossági ügyben válik kulcsszereplővé.', 'A nyomozó', 107, NULL, 'https://www.youtube.com/watch?v=9CrLIEwkN7w'),
(141, 2007, 'Egy vasúti őr tanúja lesz egy bűnténynek és a pénz csábításának.', 'A londoni férfi', 132, 'https://m.media-amazon.com/images/M/MV5BZjk3ODc3ZmQtNzE0Yy00YmMxLWFmYWMtNjdlYzJmMjA0NWRkXkEyXkFqcGc@._V1_.jpg', 'https://www.youtube.com/watch?v=Kln8t-5RYxw'),
(142, 2014, 'Egy afrikai focista Magyarországra kerül, ahol rabszolgaságba esik.', 'Délibáb', 91, NULL, 'https://www.youtube.com/watch?v=fS9tD-RlHBI'),
(143, 2011, 'Az 1950-es években egy fiatal titkos ügynök próbára van téve.', 'A vizsga', 89, NULL, 'https://www.youtube.com/watch?v=eQXXuC9eaYQ'),
(144, 1985, 'Egy kis falu lakóinak mindennapjait bemutató történet.', 'Az én kis falum', 98, NULL, 'https://www.youtube.com/watch?v=sRkYEYKQjsg'),
(145, 1999, 'Egy magyar mentalista segít a rendőrségnek egy rejtélyes ügyben.', 'Simon mágus', 100, NULL, 'https://www.youtube.com/watch?v=H0Ubj7RlJsY'),
(146, 1985, 'Egy baráti társaság életének és álmainak története.', 'A nagy generáció', 97, NULL, 'https://www.youtube.com/watch?v=XDzU5UsLxRo'),
(147, 2008, 'Egy szélhámos kiforgatja a gazdag nőket a vagyonukból.', 'Kaméleon', 104, NULL, 'https://www.youtube.com/watch?v=7-H9UQb2EqM'),
(148, 2006, 'Egy tornász élete a fegyelemről és a múlt árnyékairól.', 'Fehér tenyér', 100, NULL, 'https://www.youtube.com/watch?v=Dh8czRR25X4'),
(149, 2013, 'Egy mentős különös módon pénzt keres a halottakkal.', 'Isteni műszak', 100, NULL, 'https://www.youtube.com/watch?v=iIfYbQjuIWM'),
(150, 2019, 'Egy szélhámos menekülés közben egy özvegy életébe csöppen.', 'Apró mesék', 112, NULL, 'https://www.youtube.com/watch?v=MwBolbr8g0s');

-- --------------------------------------------------------

--
-- Table structure for table `movie_actors`
--

CREATE TABLE `movie_actors` (
  `movie_id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `movie_actors`
--

INSERT INTO `movie_actors` (`movie_id`, `actor_id`) VALUES
(104, 1),
(108, 1),
(102, 2),
(103, 3),
(104, 5),
(105, 5),
(117, 5),
(102, 7),
(117, 7),
(146, 7),
(109, 8),
(112, 11),
(129, 12),
(114, 13),
(136, 13),
(115, 14),
(122, 14),
(123, 14),
(147, 14),
(136, 15),
(147, 15),
(105, 19),
(124, 19),
(143, 20),
(122, 21),
(123, 22),
(117, 23),
(124, 23),
(146, 23),
(124, 24),
(127, 26),
(111, 29),
(124, 29),
(130, 29),
(146, 29),
(101, 30),
(101, 31),
(119, 31),
(101, 32),
(101, 33),
(101, 34),
(101, 35),
(102, 36),
(102, 37),
(102, 38),
(103, 39),
(103, 40),
(109, 40),
(104, 41),
(104, 42),
(109, 42),
(105, 43),
(107, 44),
(107, 45),
(107, 46),
(107, 47),
(108, 48),
(108, 49),
(109, 50),
(109, 51),
(110, 52),
(110, 53),
(111, 54),
(111, 55),
(111, 56),
(111, 57),
(129, 57),
(112, 58),
(113, 59),
(113, 60),
(145, 60),
(113, 61),
(130, 61),
(114, 68),
(114, 69),
(115, 75),
(121, 75),
(115, 76),
(116, 77),
(116, 78),
(116, 79),
(131, 79),
(118, 80),
(118, 81),
(119, 82),
(120, 83),
(120, 84),
(120, 85),
(121, 86),
(123, 87),
(123, 88),
(124, 89),
(137, 89),
(143, 89),
(124, 90),
(125, 91),
(125, 92),
(125, 93),
(126, 94),
(126, 95),
(126, 96),
(127, 97),
(127, 98),
(127, 99),
(147, 99),
(127, 100),
(140, 100),
(133, 102),
(129, 104),
(129, 105),
(129, 106),
(130, 107),
(143, 107),
(131, 108),
(131, 109),
(131, 110),
(132, 111),
(133, 112),
(133, 113),
(150, 113),
(134, 114),
(134, 115),
(134, 116),
(135, 117),
(135, 118),
(136, 119),
(136, 120),
(140, 120),
(137, 121),
(137, 122),
(137, 123),
(137, 124),
(138, 125),
(138, 126),
(138, 127),
(138, 128),
(139, 129),
(139, 130),
(140, 131),
(140, 132),
(140, 133),
(141, 134),
(141, 135),
(141, 136),
(141, 137),
(142, 138),
(142, 139),
(142, 140),
(144, 141),
(144, 142),
(144, 143),
(145, 144),
(145, 145),
(147, 146),
(147, 147),
(147, 148),
(148, 149),
(149, 150),
(149, 151),
(149, 152),
(150, 153),
(150, 154),
(150, 155);

-- --------------------------------------------------------

--
-- Table structure for table `movie_directors`
--

CREATE TABLE `movie_directors` (
  `movie_id` int(11) NOT NULL,
  `director_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `movie_directors`
--

INSERT INTO `movie_directors` (`movie_id`, `director_id`) VALUES
(101, 1),
(102, 2),
(119, 2),
(139, 2),
(103, 3),
(104, 4),
(105, 5),
(106, 6),
(107, 7),
(108, 8),
(109, 9),
(120, 9),
(110, 10),
(146, 12),
(113, 13),
(127, 13),
(145, 13),
(114, 14),
(115, 15),
(116, 16),
(118, 16),
(117, 17),
(121, 20),
(136, 22),
(122, 31),
(150, 31),
(123, 32),
(147, 32),
(124, 33),
(125, 34),
(126, 35),
(128, 36),
(129, 37),
(130, 38),
(111, 39),
(112, 40),
(131, 41),
(132, 42),
(133, 43),
(134, 44),
(135, 44),
(141, 44),
(138, 47),
(140, 47),
(137, 48),
(143, 49),
(142, 50),
(148, 50),
(144, 51),
(149, 52);

-- --------------------------------------------------------

--
-- Table structure for table `movie_genres`
--

CREATE TABLE `movie_genres` (
  `movie_id` int(11) NOT NULL,
  `genre_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `movie_genres`
--

INSERT INTO `movie_genres` (`movie_id`, `genre_id`) VALUES
(101, 1),
(102, 1),
(105, 1),
(107, 1),
(108, 1),
(109, 1),
(110, 1),
(113, 1),
(115, 1),
(116, 1),
(117, 1),
(118, 1),
(119, 1),
(120, 1),
(121, 1),
(122, 1),
(123, 1),
(125, 1),
(127, 1),
(128, 1),
(129, 1),
(130, 1),
(131, 1),
(132, 1),
(133, 1),
(134, 1),
(135, 1),
(136, 1),
(137, 1),
(138, 1),
(139, 1),
(140, 1),
(141, 1),
(142, 1),
(143, 1),
(145, 1),
(146, 1),
(147, 1),
(148, 1),
(150, 1),
(103, 2),
(124, 2),
(102, 3),
(104, 3),
(111, 3),
(112, 3),
(114, 3),
(116, 3),
(121, 3),
(124, 3),
(126, 3),
(130, 3),
(132, 3),
(140, 3),
(144, 3),
(149, 3),
(106, 4),
(101, 5),
(107, 5),
(103, 6),
(108, 6),
(110, 6),
(115, 6),
(117, 6),
(122, 6),
(123, 6),
(126, 6),
(147, 6),
(120, 7),
(106, 8),
(113, 9),
(113, 10),
(128, 11),
(136, 11),
(138, 11),
(141, 11),
(143, 11),
(106, 12),
(108, 12),
(120, 12),
(114, 13),
(116, 13),
(107, 14),
(114, 15),
(127, 15),
(129, 15),
(137, 15),
(101, 19),
(104, 19),
(108, 19),
(109, 19),
(110, 19),
(131, 19),
(133, 19),
(103, 20),
(118, 21),
(136, 21),
(140, 21),
(141, 21),
(142, 22);

-- --------------------------------------------------------

--
-- Table structure for table `ratings`
--

CREATE TABLE `ratings` (
  `rating_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `movie_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `review` text,
  `rating_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ratings`
--

INSERT INTO `ratings` (`rating_id`, `user_id`, `movie_id`, `rating`, `review`, `rating_date`) VALUES
(1, 1, 101, 5, 'Nagyszerű történet, kiváló színészek.', '2023-01-15'),
(2, 2, 102, 4, 'Mély és elgondolkodtató.', '2023-01-18'),
(3, 3, 103, 3, 'Humoros, de egy kicsit hosszú.', '2023-01-20'),
(4, 4, 104, 5, 'Fantasztikus klasszikus!', '2023-02-05'),
(5, 5, 105, 4, 'Szívszorító történet.', '2023-02-10'),
(6, 6, 106, 5, 'Gyerekkorom kedvence!', '2023-03-01'),
(7, 7, 107, 3, 'Jó, de nem kiemelkedő.', '2023-03-10'),
(8, 8, 108, 5, 'Kiváló történelmi film.', '2023-03-15'),
(9, 9, 109, 5, 'Elképesztően jó színészi alakítás.', '2023-04-01'),
(11, 11, 111, 4, 'Igazi klasszikus humor.', '2023-04-20'),
(13, 13, 113, 5, 'Művészi alkotás.', '2023-05-10'),
(14, 14, 114, 3, 'Furcsa, de szórakoztató.', '2023-06-01'),
(16, 16, 116, 2, 'Túl szürreális nekem.', '2023-07-01'),
(17, 17, 117, 4, 'Széchenyi története nagyon inspiráló.', '2023-07-10'),
(18, 18, 118, 4, 'Csendes, de lenyűgöző.', '2023-07-25'),
(19, 19, 119, 4, 'Megható családi dráma.', '2023-08-05'),
(20, 20, 120, 5, 'Egy igazán időtálló klasszikus.', '2023-08-15'),
(21, 21, 121, 4, 'Nostalgikus és életszagú.', '2023-09-01'),
(22, 22, 122, 4, 'Történelmileg nagyon hiteles.', '2023-09-15'),
(23, 23, 123, 5, 'Romantikus és izgalmas.', '2023-09-20'),
(24, 24, 124, 3, 'Vicces, de néha túl sztereotipikus.', '2023-10-01'),
(25, 25, 125, 4, 'Érdekes karakterek.', '2023-10-12'),
(26, 26, 126, 4, 'Jó történelmi humor.', '2023-10-25'),
(27, 27, 127, 4, 'Lenyűgöző és elgondolkodtató.', '2023-11-01'),
(28, 28, 128, 4, 'Szokatlan nézőpont egy állatról.', '2023-11-10'),
(29, 29, 129, 4, 'Gyönyörű irodalmi adaptáció.', '2023-11-12'),
(30, 30, 130, 5, 'Tökéletes filmélmény.', '2023-11-15'),
(31, 20, 101, 3, 'Nem tetszett >:(', '2025-02-27'),
(32, 10, 114, 2, 'nem tetszik.', '2025-02-27'),
(35, 52, 120, 5, 'Great movie!', '2025-03-04'),
(38, 52, 114, 5, 'jajj de szereteeem wááá', '2025-03-13'),
(41, 23, 126, 3, 'elég mid', '2025-04-13');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `registration_date` date NOT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `registration_date`, `role`) VALUES
(1, 'user01', 'user01@example.com', 'b01ce21ce5ac38191fcf0fb87c71f53756b2c57e57046f7320a463f1dba3e209', '2022-05-01', 'user'),
(2, 'user02', 'user02@example.com', '1321166e0e6eaa14148b1d5a47f4bdfabdabe11800a4579fbf3f77ba55e86517', '2022-06-15', 'user'),
(3, 'user03', 'user03@example.com', '433aa7f21428c6b75543cdb46caf31f6828e9a78d262dd5382eeb381c8c20787', '2022-07-20', 'user'),
(4, 'user04', 'user04@example.com', '054e2ac1e5b89caf7446f6a6fee681d2259ce871149e162885b4263e6d77c852', '2022-08-05', 'user'),
(5, 'user05', 'user05@example.com', '57a319ac89097ea47a14626564ba96f439bdeb213c31869603ec9efd4c612675', '2022-09-12', 'user'),
(6, 'user06', 'user06@example.com', 'f1e150a8730a3d23729b4ec12392cb122f81a91fdcce7039f28e0a93cbdef17a', '2022-10-01', 'user'),
(7, 'user07', 'user07@example.com', '7d8683503df3a53c54b6d9d18c9591ccb2369bd9c45739f93c34d274aa9dabae', '2022-11-15', 'user'),
(8, 'user08', 'user08@example.com', 'e5967501373f7fbf336de9f99cde06d4b8bcd0326d670b13c3ee771d23df0255', '2022-12-25', 'user'),
(9, 'user09', 'user09@example.com', 'bba783357187d99e3734fb568f1b901dfcb22050aa06a2cdef06e0531ee13712', '2023-01-10', 'user'),
(10, 'user10', 'user10@example.com', '9bf5fe02f00be85700e3e665f83ef4b933f37c032f935619e4d9474359d2ad11', '2023-02-14', 'user'),
(11, 'user11', 'user11@example.com', '8d95ce09bbdabd9d82a5397ca8768e11cee8c4d3240554939b75c0c847a65f57', '2023-03-05', 'user'),
(12, 'user12', 'user12@example.com', 'd697c6dc67eea5aa93b4e8888a8601216ba3b0958161c4e779d54bff61099df6', '2023-03-18', 'user'),
(13, 'user13', 'user13@example.com', '0c234922e5408c4af3af38288cb07f85c2fe8d354ec0d90bf722a3ca8fb320de', '2023-04-01', 'user'),
(14, 'user14', 'user14@example.com', 'ce8a146893cbda37ea920d3df3587022998a5f47a110d71af541497acbfa0f8b', '2023-04-15', 'user'),
(15, 'user15', 'user15@example.com', '21cdcf752bb5ec64d41290d244a85978b97a46b049cc7d068d380f0d6f619ea3', '2023-05-20', 'user'),
(16, 'user16', 'user16@example.com', 'acaf749ea2842470b1f8a226f3a58f235d24b6f0701cf4231f1c945f178ee694', '2023-06-10', 'user'),
(17, 'user17', 'user17@example.com', '770ed669934d123ade1232cb17d1bf060a03414145c01fa7c442054e3cbd6050', '2023-07-01', 'user'),
(18, 'user18', 'user18@example.com', '5695159addb2c5c3c56a27f1540e213da49e45dca0757c1dd5a4a4cbbc7a7ed5', '2023-08-25', 'user'),
(19, 'user19', 'user19@example.com', '6bd744fa602140f8002c41d6de7c3bae4019d89a3e79526afa9b5fd72205558d', '2023-09-05', 'user'),
(20, 'user20', 'user20@example.com', 'b9b63b2c402091bcb7cd8220cf7cd03fe9391d670a23106d0513743ab37a1ef6', '2023-10-15', 'user'),
(21, 'user21', 'user21@example.com', '5dd2df5864c4c28f0e41a7e6a5e063d4ace57aef6fa055cc66780f515c588ef1', '2023-10-30', 'user'),
(22, 'user22', 'user22@example.com', '149079bcec8dd9e73feda93f42c8d909366f28f795afa8169ad0e4416803d0a5', '2023-11-05', 'user'),
(23, 'user23', 'user23@example.com', '734b4ef493edb4e53e2df0b709f17c3b891ffe995167350b7d547b4fa57cd83b', '2023-11-10', 'user'),
(24, 'user24', 'user24@example.com', '9430f5556c8cc3982c63cb6762566e006fbc7e299b4255cfa569ecc1be7a0b06', '2023-11-12', 'user'),
(25, 'user25', 'user25@example.com', 'd18e22a2560dc2bac844c91bd868955cd5a3ea1d7a9c3504516d47f86313e6be', '2023-11-13', 'user'),
(26, 'user26', 'user26@example.com', '2a65a1338108372f2422eafefc8809ae516f2039665ab721d0ffc0343d6707ad', '2023-11-14', 'user'),
(27, 'user27', 'user27@example.com', 'c25da1436413639abc82c7891467ded58b86956ef793cc5ef72c6867b6d5e144', '2023-11-15', 'user'),
(28, 'user28', 'user28@example.com', '1bb36c13be34479f487d2d42d15b19ac3ba52f329461376aae7c5f516f4e346b', '2023-11-16', 'user'),
(29, 'user29', 'user29@example.com', '95eec19390b1ae11e0dfe6ae5548c92fb3da67f56fb4f01b731deb039c35ec3f', '2023-11-17', 'user'),
(30, 'user30', 'user30@example.com', 'e8a940d4972a7e645e4ea1d712ff1f0c79ec4243378c47e114ca71be2af568e9', '2023-11-18', 'user'),
(32, 'ákoska', 'elkepeszto1995@gmail.com', '*0821C7D9F57AAB8C9ABF26B56F573571229FA626', '2025-01-17', 'user'),
(36, 'elsoezenaneven', 'nagyb6605@gmail.com', 'igeniskapitány0123!', '2025-01-17', 'user'),
(44, 'petike', 'horvathtibor@gmail.com', '082635b2eb16500b82ea6b7a05d175b233e907c8f33c9eb60acda370fd386b094ff2371aa1c0e750b0687e34aa210766fb57460b3cf31290d847a7570a464b91', '2025-01-17', 'admin'),
(45, 'fasz', 'szopo', 'jaha', '2025-01-31', 'user'),
(46, 'ujfelhasználó', 'uj@example.com', 'ujjelszó', '2025-02-25', 'user'),
(48, 'ujfelhasználó2', 'uj@exampple.com', 'Ujjelszó1!', '2025-02-26', 'user'),
(49, 'faszosom', 'uj@valami.com', 'Ujjelszó1!', '2025-02-26', 'user'),
(50, 'hatalma', 'faszosom@gmail.hu', 'Hatalom6!', '2025-02-27', 'user'),
(51, 'hatalmaa', 'faszossom@gmail.hu', 'Hatalom6!', '2025-03-04', 'user'),
(52, 'wáááopoo', 'vicces@gmail.hu', 'Hatalom6!', '2025-03-04', 'user'),
(53, 'tesztfelhasználó', 'teszt@example.com', 'titkosjelszó', '2023-10-01', 'user'),
(56, 'ákoskaa', 'faszm@gmail.com', 'igeniskapitány0123!', '2025-03-13', 'user'),
(57, 'trallala', 'trallalero@gmail.com', '$2a$10$CKf62aHNooKglXM4PN0APuU4srVeLMScYUXle8zbAIoy3sK9K3rG.', '2025-03-13', 'user'),
(59, 'waawaa', 'madness@gmail.com', 'Porquedillo4!', '2025-03-29', 'user');

-- --------------------------------------------------------

--
-- Table structure for table `user_favorites`
--

CREATE TABLE `user_favorites` (
  `favorite_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `movie_id` int(11) NOT NULL,
  `added_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `user_favorites`
--

INSERT INTO `user_favorites` (`favorite_id`, `user_id`, `movie_id`, `added_at`) VALUES
(1, 56, 123, '2025-04-12 20:42:28'),
(3, 56, 141, '2025-04-12 21:16:18'),
(4, 56, 111, '2025-04-13 18:39:29');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `actors`
--
ALTER TABLE `actors`
  ADD PRIMARY KEY (`actor_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `directors`
--
ALTER TABLE `directors`
  ADD PRIMARY KEY (`director_id`);

--
-- Indexes for table `genres`
--
ALTER TABLE `genres`
  ADD PRIMARY KEY (`genre_id`);

--
-- Indexes for table `movies`
--
ALTER TABLE `movies`
  ADD PRIMARY KEY (`movie_id`);

--
-- Indexes for table `movie_actors`
--
ALTER TABLE `movie_actors`
  ADD PRIMARY KEY (`movie_id`,`actor_id`),
  ADD KEY `fk_actor_id` (`actor_id`);

--
-- Indexes for table `movie_directors`
--
ALTER TABLE `movie_directors`
  ADD PRIMARY KEY (`movie_id`,`director_id`),
  ADD KEY `director_id` (`director_id`);

--
-- Indexes for table `movie_genres`
--
ALTER TABLE `movie_genres`
  ADD PRIMARY KEY (`movie_id`,`genre_id`),
  ADD KEY `genre_id` (`genre_id`);

--
-- Indexes for table `ratings`
--
ALTER TABLE `ratings`
  ADD PRIMARY KEY (`rating_id`),
  ADD KEY `fk_ratings_user` (`user_id`),
  ADD KEY `fk_ratings_movie` (`movie_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `unique_username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_favorites`
--
ALTER TABLE `user_favorites`
  ADD PRIMARY KEY (`favorite_id`),
  ADD UNIQUE KEY `unique_favorite` (`user_id`,`movie_id`),
  ADD KEY `movie_id` (`movie_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `actors`
--
ALTER TABLE `actors`
  MODIFY `actor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

--
-- AUTO_INCREMENT for table `directors`
--
ALTER TABLE `directors`
  MODIFY `director_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `genres`
--
ALTER TABLE `genres`
  MODIFY `genre_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `movies`
--
ALTER TABLE `movies`
  MODIFY `movie_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=151;

--
-- AUTO_INCREMENT for table `ratings`
--
ALTER TABLE `ratings`
  MODIFY `rating_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `user_favorites`
--
ALTER TABLE `user_favorites`
  MODIFY `favorite_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `movie_actors`
--
ALTER TABLE `movie_actors`
  ADD CONSTRAINT `fk_actor_id` FOREIGN KEY (`actor_id`) REFERENCES `actors` (`actor_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_movie_id` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `movie_directors`
--
ALTER TABLE `movie_directors`
  ADD CONSTRAINT `fk_director` FOREIGN KEY (`director_id`) REFERENCES `directors` (`director_id`),
  ADD CONSTRAINT `fk_movie` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`),
  ADD CONSTRAINT `movie_directors_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `movie_directors_ibfk_2` FOREIGN KEY (`director_id`) REFERENCES `directors` (`director_id`) ON DELETE CASCADE;

--
-- Constraints for table `movie_genres`
--
ALTER TABLE `movie_genres`
  ADD CONSTRAINT `fk_movie_genre` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `movie_genres_ibfk_1` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `movie_genres_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`) ON DELETE CASCADE;

--
-- Constraints for table `ratings`
--
ALTER TABLE `ratings`
  ADD CONSTRAINT `fk_ratings_movie` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ratings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `user_favorites`
--
ALTER TABLE `user_favorites`
  ADD CONSTRAINT `user_favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `user_favorites_ibfk_2` FOREIGN KEY (`movie_id`) REFERENCES `movies` (`movie_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
