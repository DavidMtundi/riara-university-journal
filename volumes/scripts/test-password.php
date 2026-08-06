<?php
$hash = '$2y$12$bIpgUwW8gS0Xkw.EiyPNe.ybswUz2Wa407/jWTLyQD64FekeR.m/S';
echo password_verify('root', $hash) ? "PASSWORD_OK\n" : "PASSWORD_FAIL\n";
