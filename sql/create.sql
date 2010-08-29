# CocoaMySQL dump
# Version 0.7b5
# http://cocoamysql.sourceforge.net
#
# Host: localhost (MySQL 5.0.67)
# Database: sports_betting
# Generation Time: 2009-01-28 08:50:10 -0500
# ************************************************************

# Dump of table arbitrage_types
# ------------------------------------------------------------

CREATE TABLE `arbitrage_types` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;



# Dump of table arbitrages
# ------------------------------------------------------------

CREATE TABLE `arbitrages` (
  `id` int(11) NOT NULL auto_increment,
  `line1_id` int(11) default NULL,
  `line2_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `type_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=990 DEFAULT CHARSET=latin1;



# Dump of table browsers
# ------------------------------------------------------------

CREATE TABLE `browsers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;



# Dump of table games
# ------------------------------------------------------------

CREATE TABLE `games` (
  `id` int(11) NOT NULL auto_increment,
  `team1_id` int(11) default NULL,
  `team2_id` int(11) default NULL,
  `game_time` datetime default NULL,
  `sport_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2734 DEFAULT CHARSET=utf8;



# Dump of table lines
# ------------------------------------------------------------

CREATE TABLE `lines` (
  `id` int(11) NOT NULL auto_increment,
  `team_id` int(11) default NULL,
  `game_id` int(11) default NULL,
  `spread` float default NULL,
  `spread_movement` int(11) default '0',
  `spread_vig` float default NULL,
  `spread_vig_movement` int(11) default '0',
  `money_line` float default NULL,
  `money_line_movement` int(11) default '0',
  `over_under` varchar(255) default NULL,
  `total_points` float default NULL,
  `total_points_movement` int(11) default '0',
  `total_points_vig` float default NULL,
  `total_points_vig_movement` int(11) default '0',
  `browser_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `team` (`team_id`),
  KEY `browser` (`browser_id`),
  KEY `game` (`game_id`),
  KEY `create_date` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=217847 DEFAULT CHARSET=utf8;



# Dump of table opportunities
# ------------------------------------------------------------

CREATE TABLE `opportunities` (
  `id` int(11) NOT NULL auto_increment,
  `line1_id` int(11) default NULL,
  `line2_id` int(11) default NULL,
  `type_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



# Dump of table pages
# ------------------------------------------------------------

CREATE TABLE `pages` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(255) default NULL,
  `browser_id` int(11) default NULL,
  `sport_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;



# Dump of table schema_migrations
# ------------------------------------------------------------

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table sports
# ------------------------------------------------------------

CREATE TABLE `sports` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;



# Dump of table team_synonyms
# ------------------------------------------------------------

CREATE TABLE `team_synonyms` (
  `id` int(11) NOT NULL auto_increment,
  `synonym` varchar(255) default NULL,
  `team_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `sport_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=261 DEFAULT CHARSET=latin1;



# Dump of table teams
# ------------------------------------------------------------

CREATE TABLE `teams` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `sport_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=382 DEFAULT CHARSET=utf8;



