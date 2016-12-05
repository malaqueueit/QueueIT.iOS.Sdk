import Foundation

class StatusDTO {
    var eventDetails: EventDTO?
    var redirectDto: RedirectDTO?
    var widgets: [WidgetDTO]?
    var nextCallMSec: Int
    var rejectDto: RejectDTO?
    
    init(_ eventDetails: EventDTO?, _ redirectDto: RedirectDTO?, _ widgets: [WidgetDTO]?, _ nextCallMSec: Int, _ rejectDto: RejectDTO?) {
        self.eventDetails = eventDetails
        self.redirectDto = redirectDto
        self.widgets = widgets
        self.nextCallMSec = nextCallMSec
        self.rejectDto = rejectDto
    }
}
