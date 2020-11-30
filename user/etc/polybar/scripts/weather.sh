#!/bin/sh

# Fetch and process weather data from OpenWeatherMap.

err_str=" N/A"

fetch_coords()
{
    # Fetch geographic coordinates based off of our public IP address.
    local coords_url="https://ipapi.co/latlong/"
    local coords="$(curl -Ls "$coords_url")"
    [ "$?" -eq 0 ] && echo "$coords" || return 1
}

# $1: API Key.
# $2: City ID. If not given, weather will be fetched based off of our geographic coordinates.
fetch_weather()
{
    [ -z "$1" ] && return 3

    local units="metric"

    if [ "$2" ]; then
        local weather_url="https://api.openweathermap.org/data/2.5/weather?id=$2&units=$units&appid=$1"
    else
        local coords="$(fetch_coords)"
        if [ "$?" -eq 0 ]; then
            local lat="${coords%%,*}"
            local lon="${coords##*,}"
            local weather_url="https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=$units&appid=$1"
        fi
    fi

    local weather="$(curl -Ls "$weather_url")"
    [ "$?" -eq 0 ] && echo "$weather" || return 2
}

# $1: Weather data to parse.
parse_weather()
{
    local icon=""

    local temp="$(echo "$1" | jq '.main.temp')"
    local condition="$(echo "$1" | jq '.weather[0].main' | tr -d \")"
    local description="$(echo "$1" | jq '.weather[0].description' | tr -d \")"
    local sunrise="$(echo "$1" | jq '.sys.sunrise')"
    local sunset="$(echo "$1" | jq '.sys.sunset')"

    local current_time="$(date +%s)"
    if [ "$current_time" -ge "$sunrise" ] && [ "$current_time" -lt "$sunset" ]; then
        local is_daytime=true
    fi

    case "$condition" in
        Clouds)
            case "$description" in
                few*|scattered*)
                    [ "$is_daytime" = true ] && icon="" || icon=""
                    ;;
                *)
                    icon=""
                    ;;
            esac
            ;;
        Rain)
            case "$description" in
                light*)
                    [ "$is_daytime" = true ] && icon="" || icon=""
                    ;;
                very*|extreme*|"heavy intensity shower rain"|ragged*)
                    icon=""
                    ;;
                freezing*)
                    icon=""
                    ;;
                *)
                    icon=""
                    ;;
            esac
            ;;
        Drizzle)
            icon=""
            ;;
        Thunderstorm)
            icon=""
            ;;
        Snow)
            icon=""
            ;;
        Mist|Smoke|Haze|Dust|Fog|Sand|Ash|Squall)
            icon=""
            ;;
        Tornado)
            icon=""
            ;;
        *)
            [ "$is_daytime" = true ] && icon="" || icon=""
            ;;
    esac

    echo "$icon $condition, ${temp%%.*}℃"
}

if [ "$OWM_API_KEY" ]; then
    [ "$OWM_CITY_ID" ] && weather="$(fetch_weather "$OWM_API_KEY" "$OWM_CITY_ID")" || weather="$(fetch_weather "$OWM_API_KEY")"
    if [ "$?" -eq 0 ]; then
        str="$(parse_weather "$weather")"
        echo "$str"
    else
        echo "$err_str"
    fi
else
    echo "$err_str"
fi
