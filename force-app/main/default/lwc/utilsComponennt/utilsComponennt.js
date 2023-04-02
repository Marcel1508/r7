import showDebugLogs from '@salesforce/label/c.showDebugLogs';
import showDebugLogsForUserIds from '@salesforce/label/c.showDebugLogsForUserIds';
import USER_ID from "@salesforce/user/Id";

export function showDebugs() {
    if(showDebugLogs == 'true')
        return true;
    const showDebugLogsStr = showDebugLogsForUserIds.split(',');
    return showDebugLogsStr.includes(USER_ID);
}