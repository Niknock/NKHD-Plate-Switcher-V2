INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
	('tape', 'Tape', 1, 0, 1),
	('tape_remover', 'Tape Remover', 5, 0, 1);

CREATE TABLE IF NOT EXISTS `plateswitcher` (
  `identifier` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `plate` varchar(50) COLLATE utf8mb4_bin DEFAULT '',
  `model` varchar(50) COLLATE utf8mb4_bin DEFAULT '',
  `paltem` varchar(50) COLLATE utf8mb4_bin DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
