extends Node
class_name RSUserMng

var l : RSLogger



func start():
	l = RSLogger.new(RSSettings.LOGGER_NAME_USER_MNG)
	l.i("Started")