
function location_data(format) {
    var loc_id = document.getElementsByName('location')[0].value;
    var date = document.getElementsByName('date_loc')[0].value; 
    window.location.href = '/weather/data/' + loc_id + '/' + date + format; //relative to domain
}


function postcode_data(format) {
    var postcode = document.getElementsByName('postcode')[0].value;
    var date = document.getElementsByName('date_postcode')[0].value; 
    window.location.href = '/weather/data/' + postcode + '/' + date + format; //relative to domain
}


function ll_prediction(format) {
    var lat = document.getElementsByName('lat')[0].value;
    var lon = document.getElementsByName('lon')[0].value;
    var period = document.getElementsByName('period_ll')[0].value; 
    window.location.href = '/weather/prediction/' + lat + '/' + lon + '/' + period + format; //relative to domain
}


function postcode_prediction(format) {
    var postcode = document.getElementsByName('postcode_prediction')[0].value;
    var period = document.getElementsByName('period_postcode')[0].value; 
    window.location.href = '/weather/prediction/' + postcode + '/' + period + format; //relative to domain
}




