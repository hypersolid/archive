
<?php
        $k = 0;
	       foreach($files as $i){
		                      $k++;
				                     list($date, $time, $path) = explode('|', $i);
						                    $path = rtrim($path);
								                   $URL = str_replace('%2F', '/', urlencode($path));
										                  if($time != 'folder'){
													                         $URL = str_replace('+', '%20', $URL);
																                }else{
																			                       $vidra = explode('/', $URL);
																					                              if(preg_match('/p(\d+)/', $vidra[1], $m)){
																									                                     $URL = 'navigate'.$m[1].'&path='.implode('/', array_splice($vidra, 2));
																													                            }
																																                   }

																																		   ?>

