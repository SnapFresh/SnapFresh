
  
        function initiate_geolocation() {  
        if (navigator.geolocation)  
        {  
            navigator.geolocation.getCurrentPosition(handle_geolocation_query, handle_errors);  
        }  
        else  
        {  
            yqlgeo.get('visitor', normalize_yql_response);  
        }  
    }  
  
    function handle_errors(error)  
    {  
        switch(error.code)  
        {  

            case error.PERMISSION_DENIED: $('#errormsg').val('user did not share geolocation data');  
            break;  
  
            case error.POSITION_UNAVAILABLE: $('#errormsg').val('could not detect current position');  
            break;  
  
            case error.TIMEOUT: $('#errormsg').val('retrieving position timedout');  

            break;  
  
            default: console.log("unknown error");  
            break;  
        }  
    }  
  
    function normalize_yql_response(response)  
    {  
        if (response.error)  
        {  
            var error = { code : 0 };  
            handle_error(error);  
            return;  
        }  
  
        var position = {  
            coords :  
            {  
                latitude: response.place.centroid.latitude,  
                longitude: response.place.centroid.longitude  
            },  
            address :  
            {  
                city: response.place.locality2.content,  
                region: response.place.admin1.content,  
                country: response.place.country.content  
            }  
        };  
  
        handle_geolocation_query(position);  
    }    
  
        function handle_geolocation_query(position){  
            $('#lat').val(position.coords.latitude);
            $('#lon').val(position.coords.longitude);
        };
    </script>
    