#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Date::Parse::Modern;

ok(!defined(strtotime('foo')), 'Bogus string');
ok(!defined(strtotime(''))   , 'Empty string');

# This will vary based on a users timezone
ok(strtotime('1970-01-01')              <  86400, 'Epoch local timezone');
ok(strtotime('1970-01-01 00:00:00 UTC') == 0    , 'Epoch with time');
ok(strtotime('1970-01-01 00:00:01 UTC') == 1    , 'Epoch + 1');

ok(strtotime('1979-02-24') == 288691200                         , 'YYYY-MM-DD');
ok(strtotime('1979/04/16') == 293097600                         , 'YYYY/MM/DD');
ok(strtotime('Sat May  8 21:24:31 2021') == 1620534271          , 'Human text string');
ok(strtotime('May  4 01:04:16') >= 1683187456                   , 'Text date WITHOUT year');
ok(strtotime('2000-02-29T12:34:56') == 951856496                , 'ISO 8601');
ok(strtotime('1995-01-24T09:08:17.1823213') == 790967297.1823213, 'ISO 8601 with milliseconds');
ok(strtotime('January 5 2023 12:53 am') == 1672908780           , 'Textual month name');
ok(strtotime('January 9 2019 12:53 pm') == 1547067180           , 'Textual month name with PM');
ok(strtotime('Mon May 10 11:09:36 MDT 2021') == 1620666576      , 'Textual timezone 1');
ok(strtotime('Jul 22 10:00:00 UTC 2002') == 1027332000          , 'UTC timezone');
ok(strtotime('21/dec/93 17:05') == 756522300                    , 'Short form 1');
ok(strtotime('dec/21/93 17:05') == 756522300                    , 'Short form 2');
ok(strtotime('Dec/21/1993 17:05:00') == 756522300               , 'Short form 3');
ok(strtotime('10:00:00') >= 1673632800                          , 'Time only');
ok(strtotime('1994-11-05T13:15:30Z') == 784041330               , 'ISO 8601 T+Z');
ok(strtotime('2002-07-22 10:00Z') == 1027296000                 , 'ISO 8601 HH:MMZ');

ok(strtotime('Wed, 16 Jun 94 07:29:35 CST') == 771773375          , 'Textual timezone 2');
ok(strtotime('Mon, 14 Nov 1994 11:34:32 -0500 (EST)') == 784830872, 'Numeric and textual TZ offset');
ok(strtotime('Thu, 13 Oct 94 10:13:13 +0700') == 782017993        , 'Numeric timezone offset');

done_testing();
