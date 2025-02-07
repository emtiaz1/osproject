#!/bin/bash

# Arrays to store parking data
declare -a parking_spaces
declare -a vehicles
declare -a vehicle_types
declare -a tickets

# Constants
TOTAL_SPACES=10
VEHICLE_TYPE=("Car" "Motorcycle" "Truck")
FEE=(20 10 50)

# Initialize parking spaces
initialize_parking() {
    for ((i = 0; i < TOTAL_SPACES; i++)); do
        parking_spaces[i]=0 # 0 indicates vacant
    done
    echo "Parking system initialized with $TOTAL_SPACES spaces."
}

# Generate a random ticket
generate_ticket() {
    echo $((RANDOM % 10000))"-"${VEHICLE_TYPE[$1]::1}$(date +%s%N | cut -c10-12)
}

# Register a vehicle entry
register_entry() {
    echo "Enter License Plate Number:"
    read license_plate
    echo "Select Vehicle Type:"
    echo "1. Car"
    echo "2. Motorcycle"
    echo "3. Truck"
    read vehicle_type

    if [[ $vehicle_type -lt 1 || $vehicle_type -gt 3 ]]; then
        echo "Invalid vehicle type. Try again."
        return
    fi

    # Find the first available parking space
    for ((i = 0; i < TOTAL_SPACES; i++)); do
        if [[ ${parking_spaces[i]} -eq 0 ]]; then
            parking_spaces[i]=1 # Mark space as occupied
            vehicles[i]=$license_plate
            vehicle_types[i]=$((vehicle_type - 1))
            ticket=$(generate_ticket $((vehicle_type - 1)))
            tickets[i]=$ticket
            echo "Vehicle registered! Ticket: $ticket, Space: $((i + 1))"
            return
        fi
    done

    echo "Parking lot is full! Cannot register vehicle."
}

# Exit a vehicle
exit_vehicle() {
    echo "Enter Ticket Number:"
    read ticket

    for ((i = 0; i < TOTAL_SPACES; i++)); do
        if [[ ${tickets[i]} == "$ticket" ]]; then
            parking_spaces[i]=0 # Vacate the space
            fee=${FEE[${vehicle_types[i]}]}
            echo "Vehicle with License Plate: ${vehicles[i]} exited."
            echo "Parking fee: $fee"
            unset vehicles[i]
            unset vehicle_types[i]
            unset tickets[i]
            return
        fi
    done

    echo "Invalid ticket! Vehicle not found."
}

# Check parking lot status
check_status() {
    echo "Parking Lot Status:"
    for ((i = 0; i < TOTAL_SPACES; i++)); do
        if [[ ${parking_spaces[i]} -eq 0 ]]; then
            echo "Space $((i + 1)): Vacant"
        else
            echo "Space $((i + 1)): Occupied by ${VEHICLE_TYPE[${vehicle_types[i]}]} (License: ${vehicles[i]})"
        fi
    done
}

# Search for a vehicle
search_vehicle() {
    echo "Enter Ticket Number or License Plate:"
    read search_key

    for ((i = 0; i < TOTAL_SPACES; i++)); do
        if [[ ${tickets[i]} == "$search_key" || ${vehicles[i]} == "$search_key" ]]; then
            echo "Vehicle found:"
            echo "Space: $((i + 1))"
            echo "Ticket: ${tickets[i]}"
            echo "License Plate: ${vehicles[i]}"
            echo "Type: ${VEHICLE_TYPE[${vehicle_types[i]}]}"
            return
        fi
    done

    echo "Vehicle not found."
}

# Generate report
generate_report() {
    total_cars=0
    total_motorcycles=0
    total_trucks=0
    total_fee=0

    for ((i = 0; i < TOTAL_SPACES; i++)); do
        if [[ ${parking_spaces[i]} -eq 1 ]]; then
            total_fee=$((total_fee + ${FEE[${vehicle_types[i]}]}))
            case ${vehicle_types[i]} in
            0) total_cars=$((total_cars + 1)) ;;
            1) total_motorcycles=$((total_motorcycles + 1)) ;;
            2) total_trucks=$((total_trucks + 1)) ;;
            esac
        fi
    done

    echo "Parking Lot Report:"
    echo "Total Cars: $total_cars"
    echo "Total Motorcycles: $total_motorcycles"
    echo "Total Trucks: $total_trucks"
    echo "Total Revenue: $total_fee"
}

# Main Menu
main_menu() {
    while true; do
        echo "--------------------------"
        echo "Parking Management System"
        echo "--------------------------"
        echo "1. Register Entry"
        echo "2. Exit Vehicle"
        echo "3. Check Parking Lot Status"
        echo "4. Search for Vehicle"
        echo "5. Generate Report"
        echo "6. Exit"
        echo -n "Enter your choice: "
        read choice

        case $choice in
        1) register_entry ;;
        2) exit_vehicle ;;
        3) check_status ;;
        4) search_vehicle ;;
        5) generate_report ;;
        6) echo "Exiting system."; exit 0 ;;
        *) echo "Invalid choice. Try again." ;;
        esac
    done
}

# Initialize parking and start the menu
initialize_parking
main_menu

