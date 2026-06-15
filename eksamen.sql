-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 15, 2026 at 10:01 PM
-- Server version: 12.3.2-MariaDB
-- PHP Version: 8.5.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `eksamen`
--

-- --------------------------------------------------------

--
-- Table structure for table `bestillinger`
--

CREATE TABLE `bestillinger` (
  `id` int(8) NOT NULL,
  `bruker_id` int(8) NOT NULL,
  `arbok_id` int(8) NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `boker`
--

CREATE TABLE `boker` (
  `id` int(8) NOT NULL,
  `navn` varchar(100) NOT NULL,
  `skolear` varchar(50) NOT NULL,
  `beskrivelse` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `brukere`
--

CREATE TABLE `brukere` (
  `id` int(8) NOT NULL,
  `brukernavn` varchar(50) NOT NULL,
  `passord` varchar(100) NOT NULL,
  `rolle` varchar(50) NOT NULL,
  `adresse` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `brukere`
--

INSERT INTO `brukere` (`id`, `brukernavn`, `passord`, `rolle`, `adresse`) VALUES
(1, 'isak', '$2y$12$gn3vKYm87C.PJksXdwOk0et5jk9brZIrgIN6MbVW3Hhs3wqf22fAi', 'Elev', '');

-- --------------------------------------------------------

--
-- Table structure for table `roller`
--

CREATE TABLE `roller` (
  `id` int(8) NOT NULL,
  `navn` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bestillinger`
--
ALTER TABLE `bestillinger`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bestilling_bruker_id` (`bruker_id`),
  ADD KEY `bestilling_arbok_id` (`arbok_id`);

--
-- Indexes for table `boker`
--
ALTER TABLE `boker`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `brukere`
--
ALTER TABLE `brukere`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roller`
--
ALTER TABLE `roller`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bestillinger`
--
ALTER TABLE `bestillinger`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `boker`
--
ALTER TABLE `boker`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `brukere`
--
ALTER TABLE `brukere`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `roller`
--
ALTER TABLE `roller`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bestillinger`
--
ALTER TABLE `bestillinger`
  ADD CONSTRAINT `bestilling_arbok_id` FOREIGN KEY (`arbok_id`) REFERENCES `boker` (`id`),
  ADD CONSTRAINT `bestilling_bruker_id` FOREIGN KEY (`bruker_id`) REFERENCES `brukere` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
