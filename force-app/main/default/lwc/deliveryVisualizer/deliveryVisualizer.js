import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import getOppo from '@salesforce/apex/FullCalendarController.getOppo';
import heySfLogo from '@salesforce/resourceUrl/PromocashFlowHeader';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";

/**
 * @description Full Calendar JS - Lightning Web Components
 */
export default class opportunityVisualizer extends LightningElement {
//  @track eventData ;
  @track returnedOppo = [] ;
  @track finalOppo = [] ;
  SfLogo = heySfLogo ;

  renderedCallback() {
    if (showDebug) { console.log ('beforepromise');}

    Promise.all([
      console.log('inpromise'),
      loadScript(this, FullCalendarJS + '/FullCalendarJS/jquery.min.js'),
      console.log('gotjquery'),
      loadScript(this, FullCalendarJS + '/FullCalendarJS/moment.min.js'),
      console.log('gotmoment'),
      loadScript(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.js'),
      console.log('gotfullcalendarjs'),
      loadStyle(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.css'),
      console.log('gotfullcalendarcss'),
      //loadStyle(this, FullCalendarJS + '/fullcalendar.print.min.css'),
      console.log('outpromise')

    ])
    .then(() => {
      loadScript(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.js'),
      console.log('gotfullcalendarjs')
    })
    .then(() => {
      loadScript(this, FullCalendarJS + '/FullCalendarJS/locales/fr.js')
    })
    .then(() => {
      // Initialise the calendar configuration
      if (showDebug) { console.log ('beforegettasks');}
      this.getTasks();
      if (showDebug) { console.log ('aftergettasks');}
    })
    .catch(error => {
      // eslint-disable-next-line no-console
      if (showDebug) { console.log (error);}
      console.error({
        message: 'Error occured on FullCalendarJS',
        error
      });
    })
  }
  initialiseFullCalendarJs() {
   // if (showDebug) { console.log (window.location.href);
    if (showDebug) { console.log ('In nitial');}
    if (showDebug) { console.log (this.returnedOppo.length);}
    if (showDebug) { console.log ('In initial');}
    var str = window.location.href;
    //if (showDebug) { console.log (str.left());
    var pos = str.indexOf(".com/");
    var last = pos + 4;
    var tDomain = str.slice(0,last);
    for(var i = 0 ; i < this.returnedOppo.length ; i++)
    {
      this.finalOppo.push({
        start : this.returnedOppo[i].Date__c, //Heure_de_debut__c, Heure_de_fin__c
        end : this.returnedOppo[i].Date__c, //Heure_de_debut__c, Heure_de_fin__c
        title : this.returnedOppo[i].Name,
        url : tDomain+'/lightning/r/Creneau_Salesforce__c/'+this.returnedOppo[i].Id+'/view'
    });
    }
    if (showDebug) { console.log (this.finalOppo.length);}
    if (showDebug) { console.log ('Final Task Length Above');}
    const ele = this.template.querySelector('div.fullcalendarjs');
    // eslint-disable-next-line no-undef
    $(ele).fullCalendar({
      header: {
          left: 'prev,next today',
          center: 'title',
          right: 'month,basicWeek,basicDay,listWeek'
      },
      initialView: 'listWeek',
     // defaultDate: '2020-03-12',
      defaultDate: new Date(), // default day is today
      navLinks: true, // can click day/week names to navigate views
      editable: true,
      eventLimit: true, // allow "more" link when too many events
      events : this.finalOppo
    });
  }
  getTasks(){
    getOppo()
        .then(result =>{
          if (showDebug) { console.log ('creneaux');}
          if (showDebug) { console.log (JSON.parse(result));}
          this.returnedOppo = JSON.parse(result) ;
            if (showDebug) { console.log ('Object Returned');}
            this.initialiseFullCalendarJs();
            this.error = undefined;
        })
        .catch(error => {
            if (showDebug) { console.log (error);}
            if (showDebug) { console.log ('error');}
            this.error = error;
            this.outputResult = undefined;
        });
  }
}