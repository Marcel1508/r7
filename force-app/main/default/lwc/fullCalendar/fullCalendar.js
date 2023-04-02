/* eslint-disable no-restricted-globals */
/* eslint-disable no-unused-vars */
/* eslint-disable no-alert */
/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 03-17-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   07-10-2020   Amit Singh   Initial Version
**/
import { LightningElement, track, api } from 'lwc';
//import fetchAllEvents from '@salesforce/apex/FullCalendarService.fetchAllEvents';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import getSlots from '@salesforce/apex/FullCalendarController.getSlots';
import showDebug from "@salesforce/apex/Utilities.displaySystemDebug";
//document.getElementsByTagName('head')[0].innerHTML += '<meta http-equiv="Content-Security-Policy" content="default-src gap://ready file://* *; style-src \'self\' http://* https://* \'unsafe-inline\'; script-src ';self;' https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.8.0/locale-all.js ';unsafe-inline;' ';unsafe-eval;'">';
/**
 * FullCalendarJs
 * @description Full Calendar - Lightning Web Components
 */
export default class FullCalendar extends NavigationMixin(LightningElement) {
  @api deliveryType = 'Livraison';
  @api cartId = '';
  @api deliveryMethodId = '';
  @api creneauxStringIDs = '';
  @api creneauxIDs = [];
  @api creneauxReserves = false;
  @api orderId = null;
  fullCalendarJsInitialised = false;
  today;
  @track allEvents = [];
  @track testEvent = {
    id: 'id goes here',
    //title: 'title',
    start: 'strt',
    end: 'end',
    description: 'description',
    capacite: 4,
    preparation: 54,
    slotDate: 'slotDate',
    slotTimedebut: 'slotTimedebut',
    slotTimefin: 'slotTimefin'
  };
  @track selectedEvent = undefined;
  @track _selectedEventId = '';
  @track selectedEvente = false;
  @track creneauReserveString = '';
  @api
  get selectedEventId() {
    return this._selectedEventId;
  }
  set selectedEventId(val) {
    this._selectedEventId = val;
  }

  connectedCallback() {
    let rightNow = new Date();
    // Adjust for the user's time zone
    rightNow.setMinutes(
      new Date().getMinutes() - new Date().getTimezoneOffset()
    );

    // Return the date in "YYYY-MM-DD" format
    this.today = rightNow.toISOString().slice(0, 10);
  }

  /**
   * @description Standard lifecyle method 'renderedCallback'
   *              Ensures that the page loads and renders the 
   *              container before doing anything else
   */
  renderedCallback() {
    // Performs this operation only on first render
    if (showDebug) { console.log ('renderedcallback 1 ' + this.fullCalendarJsInitialised);}
    if (this.fullCalendarJsInitialised) {
      return;
    }
    this.fullCalendarJsInitialised = true;

    // Executes all loadScript and loadStyle promises
    // and only resolves them once all promises are done
    Promise.all([
      loadScript(this, FullCalendarJS + '/FullCalendarJS/jquery.min.js'),
      //loadScript(this, FullCalendarJS + '/FullCalendarJS/newFolder/jquery.js'),
      //loadScript(this, FullCalendarJS + '/FullCalendarJS/jquery-ui.min.js'),
      loadScript(this, FullCalendarJS + '/FullCalendarJS/moment.min.js'),
      loadScript(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.js'),
      //loadScript(this, FullCalendarJS + '/FullCalendarJS/newFolder/fullcalendar.js'),
      //loadScript(this, FullCalendarJS + '/FullCalendarJS/locale-all.js'),
      loadScript(this, FullCalendarJS + '/FullCalendarJS/locales/fr.js'),
      //loadScript(this, FullCalendarJS + '/FullCalendarJS/newFolder/bootstrap.datetimepicker.min.js'),
      //loadScript(this, FullCalendarJS + '/FullCalendarJS/locales-all.min.js'),
      //loadScript(this, FullCalendarJS + '/FullCalendarJS/locales-all.js'),
      loadStyle(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.css'),
      //loadStyle(this, FullCalendarJS + '/fullcalendar.print.min.css'),
      //loadScript(this, 'https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.8.0/locale-all.js'),
    ])
    .then(() => {
      loadScript(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.js'),
      loadStyle(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.css')
    })
    .then(() => {
      loadScript(this, FullCalendarJS + '/FullCalendarJS/locales/fr.js');
      
    })
    .then(() => {
      // Initialise the calendar configuration
      this.getFilteredCreneaux();
    })
    .catch(error => {
      // eslint-disable-next-line no-console
      console.error(error);
      this.dispatchEvent(new ShowToastEvent({
        title: 'Erreur',
        message: error,
        variant: 'error',
        mode: 'dismissable'})
      );
    })
  }



  /**
   * @description Initialise the calendar configuration
   *              This is where we configure the available options for the calendar.
   *              This is also where we load the Events data.
   */
  initialiseFullCalendarJs() {
    const ele = this.template.querySelector('div.fullcalendarjs');
    let allevents = this.allEvents;
    if($(ele).fullCalendar === undefined) {
      Promise.all([
        loadScript(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.js'),
      ])
      .then(() => {
        // Initialise the calendar configuration
        this.initCal();
      });
    } else {
      this.initCal();
    }

    // eslint-disable-next-line no-undef
    //calendar.setOption('locale', 'fr');
  }

  initCal() {
    try {

      const ele = this.template.querySelector('div.fullcalendarjs');
      $(ele).fullCalendar({
        locale: 'fr',
        header: {
          left: 'prev,next today',
         // center: 'title',
          right: 'month,agendaDay,agendaWeek,listWeek'
        },
        customButtons: {
          Previous: {
            text: 'Previous',
            click: function () {
              const backNavigationEvent = new FlowNavigationBackEvent();
              this.dispatchEvent(backNavigationEvent);
            }
          },
          Next: {
            text: 'Next',
            click: function () {
              const nextNavigationEvent = new FlowNavigationNextEvent();
              this.dispatchEvent(nextNavigationEvent);
            }
          }
        },
        
        themeSystem: 'standard',
        defaultView: 'agendaWeek',
        defaultDate: new Date(),
        navLinks: true,
        editable: true,
        eventLimit: true,
        eventLimitClick: 'day',
        events: this.allEvents,
        dragScroll: false,
        droppable: false,
        weekNumbers: true,
        timeFormat: 'H:mm',
        contentHeight: 450,
  
        validRange: function (nowDate) {
          return {
            start: nowDate,
            end: nowDate.clone().add(3, 'months')
          };
        },
  
        eventClick: function (event, jsEvent, view) {

          if(confirm('Vous avez choisi le ' + event.slotDate  + ' de ' + event.slotTimedebut + ' à ' + event.slotTimefin 
          + "\nCliquez sur OK puis Suivant pour passer à l'étape suivante")){
          //if(confirm('Event Clicked ' + event.title + ' Preparation time ' + event.description + 'h')){
          this.selectedEvent = event;
          this._selectedEventId = event.id;
          const attributeChangeEvent = new FlowAttributeChangeEvent('selectedEventId', this._selectedEventId);
          this.dispatchEvent(attributeChangeEvent);
          this.selectedEvente = true;
          // this.testEvent.id = event.id;   
          // this.testEvent.title = event.title;   
          // this.testEvent.preparation = event.preparation;
          // this.testEvent.capacite = event.capacite;
          // this.testEvent.description = event.description;
          // this.testEvent.start = event.start;
          // this.testEvent.end = event.end;
          $(ele).fullCalendar('getEventSources')[0].eventDefs.forEach(item => {
           // item.Color = 'white';
            item.borderColor = 'yellowgreen';
            $(ele).fullCalendar('updateEvent', item);
          });
         // event.backgroundColor = 'gray'; rgb(114, 191, 69)
          event.backgroundColor = 'yellowgreen';
          event.textColor = 'black',
          $(ele).fullCalendar('updateEvent', event);
          $(ele).fullCalendar('refetchEvents');
        }
        },
  
        dayClick: function (date, jsEvent, view) {
          jsEvent.preventDefault();
        },
      });
        
      } catch(error) {
        if (showDebug) { console.log ('Error init');}
        if (showDebug) { console.log (error);}
      }
  }

  getFilteredCreneaux() {
    getSlots({
      // deliveryMethodId: this.deliveryMethodId,
      orderId: this.orderId
    })
    .then(result => {
      this.allEvents = result.map(item => {
        return {
          id: item.id,
          editable: false,
          //title: item.title,
          start: item.dateTimeDebut,
          end: item.dateTimeFin,
          allDay: false,
          description: item.preparationtimestring,
          capacite: item.capaciteDisponible,
          preparation: item.preparationtimestring,
          slotDate: item.slotDate,
          slotTimedebut: item.slotTimedebut,
          slotTimefin: item.slotTimefin,
          //backgroundColor: "rgb(" + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + ")",
          // borderColor: "rgb(" + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + ")"
         // backgroundColor: rgb(114, 191, 69),
          textColor: 'black',
          backgroundColor: 'white',
          borderColor: 'yellowgreen'
        };
      });
      // Initialise the calendar configuration
      this.initialiseFullCalendarJs();
    })
    .catch(error => {
      window.console.error(error);
     /* this.dispatchEvent(new ShowToastEvent({
        title: 'Erreur',
        message: error.body.message,
        variant: 'error',
        mode: 'dismissable'})
      );*/
    })
    
    /*
      fetchAllEvents()
      .then(result => {
        this.allEvents = result.map(item => {
          return {
            id : item.Id,
            editable : true,
            title : item.Subject,
            start : item.ActivityDate,
            end : item.EndDateTime,
            description : item.Description,
            allDay : false,
            extendedProps : {
              whoId : item.WhoId,
              whatId : item.WhatId
            },
            //backgroundColor: "rgb(" + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + ")",
            //borderColor: "rgb(" + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + ")"
          };
        });
        // Initialise the calendar configuration
        this.initialiseFullCalendarJs();
      })
      .catch(error => {
        window.console.log(' Error Occured ', error)
      })
      .finally(()=>{
        //this.initialiseFullCalendarJs();
      })
  
    
    .finally(() => { 
      this.initialiseFullCalendarJs(); 
    })*/
  }
}