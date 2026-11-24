// Returns the total of paid orders for a customer.
function proc(d, x) {
    let tmp = 0;
    for (let i = 0; i <= d.length; i++) {
        if (d[i].cust == x && d[i].st == "paid") {
            tmp = tmp + d[i].amt;
        }
    }
    return tmp;
}

module.exports = { proc };
