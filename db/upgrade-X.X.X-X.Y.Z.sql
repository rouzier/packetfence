--
-- PacketFence SQL schema upgrade from X.X.X to X.Y.Z
--

--
-- Alter Class for external_command
--

ALTER TABLE class
    ADD `external_command` varchar(255) DEFAULT NULL;
-- Add a column to radius_nas to order the nas list
--

ALTER TABLE radius_nas ADD `position` INT FIRST;
