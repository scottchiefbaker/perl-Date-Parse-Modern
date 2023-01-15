# NAME

`Date::Parse::Modern` - Provide string to unixtime conversions

# DESCRIPTION

`Date::Parse::Modern` provides a single function `strtotime()` which takes a textual datetime string
and returns a unixtime. Initial tests shows that `Date::Parse::Modern` is about 40% faster than
`Date::Parse`. Part of this speed increase may be due to the fact that we don't support as many
"unique" string formats.

Care was given to support the most modern style strings that you would commonly run in to in log
files or on the internet. Some "weird" examples that `Date::Parse` supports but `Date::Parse::Modern`
does **not** would be:

    21 dec 17:05
    2000 10:02:18 "GMT"
    20020722T100000Z
    2002-07-22 10:00 Z

Corner cases like this were purposely not implemented because they're not commonly used and it would
affect performance of the more common strings.

# USAGE

    use Date::Parse::Modern;

`Date::Parse::Modern` exports the `strtotime()` function automatically.

# FUNCTIONS

## strtotime($string)

    my $unixtime = strtotime('1979-02-24'); # 288691200

Simply feed `strtotime()` a string with some type of date or time in it, and it will return an
integer unixtime. If the string is unparseable, or a weird error occurs, it will return `undef`.

All the "magic" in `Date::Parse::Modern` is done using regular expressions that look for common datetime
formats. Common formats like YYYY-MM-DD and HH:II:SS are easily detected and converted to the
appropriate formats. This allows the date or time to be found anywhere in the string, in (almost) any
order. In all cases, the day of the week is ignored in the input string.

**Note:** Strings without a year are assumed to be in the current year. Example: `May 15th, 10:15am`

**Note:** Strings with only a date are assumed to be at the midnight. Example: `2023-01-15`

**Note:** Strings with only time are assumed to be the current day. Example: `10:15am`

**Note:** In strings with numeric **and** textual time zone offsets, the numeric is used. Example:
`14 Nov 1994 11:34:32 -0500 (EST)`

# AUTHORS

Scott Baker <scott@perturb.org>
