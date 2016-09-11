-- MySQL dump 10.10
--
-- Host: localhost    Database: mdoc
-- ------------------------------------------------------
-- Server version	5.0.24-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES latin1 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ddm_admins`
--

DROP TABLE IF EXISTS `ddm_admins`;
CREATE TABLE `ddm_admins` (
  `id` int(11) NOT NULL auto_increment,
  `name` tinytext,
  `surname` tinytext,
  `mail` tinytext,
  `login` tinytext,
  `pass` tinytext,
  `V` int(11) default NULL,
  `U` int(11) default NULL,
  `C` int(11) default NULL,
  `D` int(11) default NULL,
  `M` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=54 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ddm_admins`
--


/*!40000 ALTER TABLE `ddm_admins` DISABLE KEYS */;
LOCK TABLES `ddm_admins` WRITE;
INSERT INTO `ddm_admins` VALUES (10,'Владимир','Варавка','','vladnik','5ac5af53c1421285aba128eef198dadb',1,1,1,1,1),(31,'!DoomsDAY','','akrasnoschekov@dstu.edu.ru','doom','ec54cf4143336b77d618dd51dd7f9021',1,1,1,1,1),(38,'kprokopenko','Прокопенко','','kprokopenko','a85a650db6e84a8a69e8f84128f14763',1,1,1,1,0),(41,'','Валявин','','prorektor','01aea66e13d9984689ba60f1779cb969',1,1,1,1,0),(15,'Дмитрий','Рогозин','drogozin@dstu.edu.eu','drogozin','d990634057b712b423029f9958b14066',1,1,1,1,0),(33,'Гость','','','student','cd73502828457d15655bbd7a63fb0bc8',1,0,0,0,0),(18,'Игорь','Богуславский','','ivb','9ac3ab8263719736bc847a44a1885409',1,1,1,1,0),(37,'Анна','Рванцова','jenny_arm@mail.ru','Jenny','1660fe5c81c4ce64a2611494c439e1ba',1,1,1,1,0),(36,'vanisimov','Анисимов','vanisimov@dstu.edu.ru','vanisimov','b615f24411e5b5ae2935022c41fd62c9',1,1,1,1,0),(40,'nmamchiz','Мамчиц','','nmamchiz','efce11221826dc438d8295e7aabe6d89',1,1,1,1,0),(42,'Александр','Кислов','','akislov','ad189e0e906f39d417a8a98394af5c32',1,1,1,1,0),(43,'','Дунаев','','doon91','f5f99ff2f418d520ac4c38ac6d0c7f15',1,1,1,1,1),(45,'','Кудряшев Сергей Борисович','','skudryshov','cc89b6af2397c7cc4d09fa5ea9e31396',1,1,1,1,0),(46,'','Лукьянов Александр Дмитриевич','','alex','5160256831bf840f1d0af550dce108cf',1,1,1,1,0),(47,'ymenshov','','','admin','5673229411ee1031badc0a948c31385f',1,1,1,1,1),(49,'aIvanov','Иванов','aivanov@dstu.edu.ru','aivanov','e7d404d69885bf40a4a6daf032e7e8ca',1,1,1,1,0),(50,'ivaschenko','Иващенко','is','byaj700','d41d8cd98f00b204e9800998ecf8427e',1,1,1,1,0),(53,'is','Иващенко','','is','a8fba16ce82982126a91f3b62b119a80',1,1,1,1,0);
UNLOCK TABLES;
/*!40000 ALTER TABLE `ddm_admins` ENABLE KEYS */;

--
-- Table structure for table `ddm_files`
--

DROP TABLE IF EXISTS `ddm_files`;
CREATE TABLE `ddm_files` (
  `fname` varchar(30) default NULL,
  `flocate` varchar(50) default NULL,
  `fsize` varchar(10) default NULL,
  `fdate` date default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ddm_files`
--


/*!40000 ALTER TABLE `ddm_files` DISABLE KEYS */;
LOCK TABLES `ddm_files` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `ddm_files` ENABLE KEYS */;

--
-- Table structure for table `ddm_news`
--

DROP TABLE IF EXISTS `ddm_news`;
CREATE TABLE `ddm_news` (
  `id` int(11) NOT NULL auto_increment,
  `time` tinytext,
  `head` tinytext,
  `content` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ddm_news`
--


/*!40000 ALTER TABLE `ddm_news` DISABLE KEYS */;
LOCK TABLES `ddm_news` WRITE;
INSERT INTO `ddm_news` VALUES (30,'08:58:45 / 04 Сенября 2009','Внимание! Будет замена почтового сервера','В недалёком будущем (конец сентября) будет произведена замена почтового сервера на более мощную машину. Количество СПАМа не уменьшится, но зато сервер будет работать безотказно. Кроме того, планируется установить на этот сервер антивирус, который будет проверять все получаемые сообщения. Раньше мы не могли этого сделать из за недостаточной производительности ЭВМ сервера.<br>В связи с этим начиная с 21.09.2009 по 30.10.2009 <b>каждому владельцу</b> ящика вида ххх@dstu.edu.ru необходимо <b>ежедневно получать</b> свою электронную почту, для предотвращения <b>потери</b> своих сообщений, так как при переходе на новый сервер письма накопившиеся в ящиках пользователей переносится <b>не будут</b>.'),(29,'10:52:29 / 28 Августа 2009  ','Если Вам надоел СПАМ(1), то давайте совместно бороться с ним.','В своё время на нашем сайте был размещён список адресов электронной почты (e-mail) всех работников ДГТУ см.<a HREF=http://static.dstu.edu.ru/email.shtml> здесь.</a> Это создавало некоторое удобство для внешних пользователей (можно сразу узнать куда послать письмо для конкретного человека). Но с другой стороны это была огромная ошибка - адреса узнали спамеры и начали рассылать свою информацию. Эксперимент с неопубликованным в этом списке ящиком e-mail показал, что за год на этот ящик не пришло ни одного СПАМ-письма.\r\n<br> Поэтому Вам (каждому) предлагается сделать следующее: <br>\r\n1. Всем, кто страдает от спама <b>переименовать</b> свой почтовый ящик, о чем написать соответствующее заявление. <br>\r\n2. Установить приобретённый ДГТУ антивирус Касперского в который входит антиспам-фильтр. Об этом подробнее рассказано <a HREF=http://proxy/info.shtml> здесь,</a> в разделе Настройка антивирусного программного обеспечения. <br>\r\n3. Изучить возможности сортировки писем вашим почтовым агентом (например Outlook Express) и сортировать письма по различным папкам. <br>\r\n4. Изучить <a HREF=http://www.securelist.com/ru/analysis/74/Kak_umenshit_potok_spama_Desyat_sovetov_dlya_chastnogo_polzovatelya>данную статью </a> и стараться следовать рекомендациям. <br>\r\n(1) СПАМ - нежелательная почтовая рассылка.  \r\n'),(31,'09:12:34 / 07 Сентября 2009','Переход на другую нуменацию адресов.','С целью дальнейшего совершенствования передачи данных по ЛВС ДГТУ с 21.09.09 по 28.09.2009 будет осуществлён переход на другую IP нумерацию для 1-2 этажа западного крыла главного корпуса. Несмотря на то, что мы постараемся сделать это максимально незаметно для пользователей, возможны различные побочные эффекты. Поэтому обо всех проблемах с локальной сетью в аудиториях 101-150 и 201-252 главного корпуса сообщайте нам в отдел администрирования сети ДГТУ.'),(33,'12:08:49 / 25 Сентября 2009','Запущен новый почтовый сервер в режиме тестовой эксплуатации.','Вчера 24.09.2009 закончена настройка и запущен в тестовую эксплуатацию почтовый сервер, обслуживающий почтовые ящики вида ххх@dstu.edu.ru. Для всех пользователей домена @dstu.edu.ru включена антивирусная проверка и антиспам фильтр. Производительность новой ЭВМ (памятьпроцессор) примерно в 100 раз больше чем старой. О возникающих проблемах сообщайте в отдел администрирования сетей ДГТУ. Как пользоваться антиспам фильтром рассказано <a HREF=http://proxy/info.shtml> здесь.</a>'),(34,'09:49:56 / 02 Октября 2009','Почтовый сервер введён в эксплуатацию.','Результаты тестовой эксплуатации почтового сервера показали: обновлённая почта работает отлично. \r\nСервер остаётся в эксплуатации. В текущем режиме он обслуживает почтовые домены <b>dstu.edu.ru</b> и <b>dstu.rnd.runnet.ru</b>,\r\nоднако, для борьбы со спамом второй домен желательно уничтожить (спам сократится в 2 раза), корме того он имеет очень длинное\r\nназвание - долго писать. Поэтому с 5.10.2009 его обслуживание будет приостановлено - до тех пор пока в отдел администрирования\r\n сетей не обратятся 7 различных пользователей (2% от общего числа) о его включении (на сегодняшний момент зарегистрированно 1 \r\nобращение).<br> \r\nВ настоящее время почтовый сервер обеспечивает:<br>\r\n<li>Приём и отправку почты по протоколам SMTP и POP3.</li>\r\n<li>Антивирусную проверку, причём зараженное письмо даже не попадает в ящик, а отправителю присылается предупреждение.</li>\r\n<li>Автоматическое определение спам-писем. Оценка ставится в 3х подзаголовках письма: X-SpamTest-Rate, \r\nX-SpamTest-Status, X-SpamTest-Status-Extended. Эти заголовки Вы можете использовать самостоятельно или при помощи AVP \r\nантиспам-модуля.</li>\r\n<li>Есть возможность заведения почтовых ящиков для <b>каждого студента</b>. Мощность сервера позволит сделать это.</li><br>\r\nДля удобства пользователей отделом администрирования сетей вводится <b>добровольная</b> возможность отказа от спама. При \r\nеё включении все письма помеченные как спам будут вообще не доставлятся в Ваш ящик. Для её включения необходимо написать до \r\n01.11.2009 письмо со своего ящика на ANTI_SPAM @ DSTU.EDU.RU со словом Согласен. ');
UNLOCK TABLES;
/*!40000 ALTER TABLE `ddm_news` ENABLE KEYS */;

--
-- Table structure for table `ddm_permissions`
--

DROP TABLE IF EXISTS `ddm_permissions`;
CREATE TABLE `ddm_permissions` (
  `id` int(11) NOT NULL auto_increment,
  `owner` int(11) default NULL,
  `permissions` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ddm_permissions`
--


/*!40000 ALTER TABLE `ddm_permissions` DISABLE KEYS */;
LOCK TABLES `ddm_permissions` WRITE;
INSERT INTO `ddm_permissions` VALUES (1,28,'gdfg'),(2,29,'gfdsg'),(3,30,'ffdff'),(4,31,'!ALL'),(5,32,'p1 p2 p3 p4'),(6,18,'p11;p13;'),(7,16,'!ALL'),(8,15,'p10;'),(9,10,'!ALL'),(10,33,'!ALL'),(11,34,'p11;'),(12,35,'p1/p2/'),(13,36,'p14;'),(14,37,'p15;p7;p8;p16;'),(15,38,'p12;'),(16,39,'p4'),(17,40,'p4;'),(18,41,'p7;p14;'),(19,42,'p11;'),(20,43,'!ALL'),(21,44,'p1;p2;p3;p5;p6;'),(22,45,'p1;p2;p3;p5;p6;'),(23,46,'p11;'),(24,47,'all'),(25,48,'p12'),(26,49,'p12;'),(27,50,'p17;'),(28,51,'p17'),(29,52,'p17;'),(30,53,'p17;');
UNLOCK TABLES;
/*!40000 ALTER TABLE `ddm_permissions` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

