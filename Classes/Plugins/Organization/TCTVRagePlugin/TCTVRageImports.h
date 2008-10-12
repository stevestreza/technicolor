#define kTVRageQuickInfoBaseURLString  @"http://www.tvrage.com/quickinfo.php"
#define kTVRageQuickInfoScheduleString  @"http://www.tvrage.com/quickschedule.php"
#define kTVRageQuickInfoShowNameURLKey @"show"
#define kTVRageQuickInfoEpisodeURLKey  @"ep"

typedef enum TCTVRageOperationType {
	TCTVRageGetShowsOperation,
	TCTVRageGetEpisodesOperation,
	TCTVRageGetEpisodeInfoOperation,
	TCTVRageGetCurrentDayScheduleOperation
} TCTVRageOperationType;
