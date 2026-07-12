# Return one page of `items`. Pages are 1-indexed (page 1 is the first page).
def page(items, page_num, per_page):
    start = page_num * per_page
    end = start + per_page
    return items[start:end]
