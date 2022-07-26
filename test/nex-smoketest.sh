#!/bin/bash

# DIR="${BASH_SOURCE%/*}"
# if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# . "$DIR/nex-include.sh"

# to ensure if 1 command fails.. build fail
set -e

# ensure prefix is pass in
if [ $# -lt 1 ] ; then
	echo "NEX smoketest needs prefix"
	echo "nex-smoketest.sh acceptance"
	exit
fi

PREFIX=$1

# check if doing local smoke test
if [ "${PREFIX}" != "local" ]; then
    echo "Remote Smoke Test in CF"
    STD_APP_URL=${PREFIX}
else
    echo "Local Smoke Test"
    STD_APP_URL=http://localhost:8000
fi

echo STD_APP_URL=${STD_APP_URL}

# Test: Create Products
echo $'\n'=== Creating a product id: the_odyssey ===
curl -s -XPOST  "${STD_APP_URL}/products" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{"id": "the_odyssey", "title": "The Odyssey", "passenger_capacity": 101, "maximum_speed": 5, "in_stock": 10}'

# Test: Get Product
echo $'\n\n'=== Getting product id: the_odyssey ===
curl -s "${STD_APP_URL}/products/the_odyssey" | jq .

# Test: Delete Product
echo $'\n'=== Creating a product id: delete_me ===
curl -s -XPOST  "${STD_APP_URL}/products" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{"id": "delete_me", "title": "delete this product", "passenger_capacity": 10, "maximum_speed": 8, "in_stock": 3}'

echo $'\n'=== Deleting product id: delete_me ===
curl -s -XDELETE "${STD_APP_URL}/products/delete_me" 

# Test: Create Order
echo $'\n\n'=== Creating Order ===
ORDER_ID=$(
    curl -s -XPOST "${STD_APP_URL}/orders" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{"order_details": [{"product_id": "the_odyssey", "price": "100000.99", "quantity": 1}]}' 
)
echo ${ORDER_ID}
ID=$(echo ${ORDER_ID} | jq '.id')

# Test: Get Order back
echo $'\n'=== Getting Order ===
curl -s "${STD_APP_URL}/orders/${ID}" | jq .