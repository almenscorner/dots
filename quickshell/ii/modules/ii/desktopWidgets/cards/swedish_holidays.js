function getEaster(year) {
    const a = year % 19, b = Math.floor(year / 100), c = year % 100;
    const d = Math.floor(b / 4), e = b % 4;
    const f = Math.floor((b + 8) / 25);
    const g = Math.floor((b - f + 1) / 3);
    const h = (19 * a + b - d - g + 15) % 30;
    const i = Math.floor(c / 4), k = c % 4;
    const l = (32 + 2 * e + 2 * i - h - k) % 7;
    const m = Math.floor((a + 11 * h + 22 * l) / 451);
    const month = Math.floor((h + l - 7 * m + 114) / 31);
    const day = ((h + l - 7 * m + 114) % 31) + 1;
    return new Date(year, month - 1, day);
}

function getHolidayMap(year) {
    const map = new Map();
    const key = (d) => `${d.getMonth()}_${d.getDate()}`;
    const addDays = (d, n) => {
        const next = new Date(d);
        next.setDate(next.getDate() + n);
        return next;
    };
    const add = (d, name) => map.set(key(d), name);

    // Svenska helgdagar med fast datum
    add(new Date(year, 0, 1),  "Nyårsdagen");
    add(new Date(year, 0, 6),  "Trettondedag jul");
    add(new Date(year, 4, 1),  "Första maj");
    add(new Date(year, 5, 6),  "Sveriges nationaldag");
    add(new Date(year, 11, 25), "Juldagen");
    add(new Date(year, 11, 26), "Annandag jul");

    const easter = getEaster(year);
    add(addDays(easter, -2), "Långfredagen");
    add(easter,              "Påskdagen");
    add(addDays(easter, 1),  "Annandag påsk");
    add(addDays(easter, 39), "Kristi himmelsfärdsdag");
    add(addDays(easter, 49), "Pingstdagen");

    // Midsummer: Saturday Jun 20–26
    for (let d = 20; d <= 26; d++) {
        const date = new Date(year, 5, d);
        if (date.getDay() === 6) { add(date, "Midsommardagen"); break; }
    }

    // All Saints: Saturday Oct 31 – Nov 6
    for (let offset = 0; offset <= 6; offset++) {
        const date = new Date(year, 9, 31 + offset);
        if (date.getDay() === 6) { add(date, "Alla helgons dag"); break; }
    }

    // Alla söndagar är i Sverige allmänna helgdagar (röda dagar)
    for (let month = 0; month < 12; month++) {
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        for (let day = 1; day <= daysInMonth; day++) {
            const date = new Date(year, month, day);
            if (date.getDay() === 0 && !map.has(key(date))) {
                add(date, "Söndag");
            }
        }
    }

    return map;
}

function getHolidayName(holidayMap, month, day) {
    return holidayMap.get(`${month}_${day}`) ?? "";
}

// Keep for backward compat
function isHoliday(holidaySet, month, day) {
    return holidaySet.has(`${month}_${day}`);
}
