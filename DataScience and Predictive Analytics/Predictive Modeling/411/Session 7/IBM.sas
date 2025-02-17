/*  Analyzing the IBM Series from Box & Jenkins */
/*  IBM Stock Price--->Daily closing stock price */
/*  May 17, 1961 to Nov. 2, 1962 */
data ibm;
    input price @@;
    t+1;
    cards;
460 457 452 459 462 459 463 479 493 490 492 498 499 497 496
 490 489 478 487 491 487 482 479 478 479 477 479 475 479 476
 476 478 479 477 476 475 475 473 474 474 474 465 466 467 471
 471 467 473 481 488 490 489 489 485 491 492 494 499 498 500
 497 494 495 500 504 513 511 514 510 509 515 519 523 519 523
 531 547 551 547 541 545 549 545 549 547 543 540 539 532 517
 527 540 542 538 541 541 547 553 559 557 557 560 571 571 569
 575 580 584 585 590 599 603 599 596 585 587 585 581 583 592
 592 596 596 595 598 598 595 595 592 588 582 576 578 589 585
 580 579 584 581 581 577 577 578 580 586 583 581 576 571 575
 575 573 577 582 584 579 572 577 571 560 549 556 557 563 564
 567 561 559 553 553 553 547 550 544 541 532 525 542 555 558
 551 551 552 553 557 557 548 547 545 545 539 539 535 537 535
 536 537 543 548 546 547 548 549 553 553 552 551 550 553 554
 551 551 545 547 547 537 539 538 533 525 513 510 521 521 521
 523 516 511 518 517 520 519 519 519 518 513 499 485 454 462
 473 482 486 475 459 451 453 446 455 452 457 449 450 435 415
 398 399 361 383 393 385 360 364 365 370 374 359 335 323 306
 333 330 336 328 316 320 332 320 333 344 339 350 351 350 345
 350 359 375 379 376 382 370 365 367 372 373 363 371 369 376
 387 387 376 385 385 380 373 382 377 376 379 386 387 386 389
 394 393 409 411 409 408 393 391 388 396 387 383 388 382 384
 382 383 383 388 395 392 386 383 377 364 369 355 350 353 340
 350 349 358 360 360 366 359 356 355 367 357 361 355 348 343
 330 340 339 331 345 352 346 352 357
 ;
 run;

/*  Plot the data to get an overall feel for it */
/*  Note that the data appears to be non-stationary */
PROC SGPLOT DATA=ibm;
    SERIES x=T y=price;
    title "IBM Daily Stock Prices 17May61 to 2Nov62";
RUN;

/*  Take the log of the data and see if stationarity can be attained */
data ibm;
    set ibm;
    t_price=log(price);
run;
/*  The answer is No! */
PROC SGPLOT DATA=ibm;
    SERIES x=T y=t_price;
    title "Log of IBM Daily Stock Prices 17May61 to 2Nov62";
RUN;

/*  Take the first of the data and see if stationarity can be attained */
data ibm;
    set ibm;
    d_price=price-lag1(price);
run;
/*  The answer is Yes! */
/*  There is increased volatility towards the end--We ignore that for the moment */
PROC SGPLOT DATA=ibm;
    SERIES x=T y=d_price;
    title "First Difference of IBM Daily Stock Prices 17May61 to 2Nov62";
RUN;

/*  Let's start with the identification step now */
/*  The ACF plot does indicate severe non-stationarity */
proc arima data=ibm;
    identify var=price;
run;

/*  Let's try this with the differenced data */
/*  The differenced series looks like WN */
proc arima data=ibm;
    identify var=d_price;
run;

/*  Let's use Proc ARIMA to fit the differenced series */
/*  Forecast 15 periods ahead */
proc arima data=ibm;
    identify var=price(1) nlag=15;
run;

/*  Note that we have not done any forecasting yet */
/*  We see a small spike at Lag1 of the ACF plot and so decide to fit a MA(1) model */
proc arima data=ibm;
    identify var=price(1);
    estimate q=1 noconstant;  /*With first differencing, the constant term drops out */
run;

/*  Forecast Now */

proc arima data=ibm;
    identify var=price(1) noprint;  /*  Suppressing the outputs */
    estimate q=1 noconstant noprint;  /*With first differencing, the constant term drops out */
    forecast lead=15;
run;