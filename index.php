<?php
$summary = file_get_contents("http://bankapi.thru.io/summary/Matthew%20Baggett");
$summary = json_decode($summary);
$answer = ($summary->total>1000)?'Yes':'No';
$tagline = "£{$summary->total}";
// Render the template.
require("template.phtml");
