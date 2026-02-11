###########################################################
#                     WEB_STORE_DB_LIB.PL
#
# Date Created: 11-15-96
# Date Last Modified: 11-26-96
#
# Copyright Info: This library was written by Gunther Birznieks
#       (gunther@clark.net) having been inspired by countless
#       other Perl authors.  Feel free to copy, cite, reference, sample,
#       borrow, resell or plagiarize the contents.  However, if you don't
#       mind, please let me know where it goes so that I can at least
#       watch and take part in the development of the memes. Information
#       wants to be free, support public domain freware.  Donations are
#       appreciated and will be spent on further upgrades and other public
#       domain scripts.
#
# Purpose: This library contains the routines that the
# Web store uses to interface with a flatfile (plain
# ASCII text file) database file.
#
# Special Note: If you wish to interface with a SQL database
# such as mSQL, this is where you do it. Simply replace the
# routines in here with routines that call the database
# engine of your choice.
#
# Main Procedures:
#  check_db_with_product_id - The web store takes
#    this procedure and double checks that the order
#    within the cart matches the product description
#    in the database. This is a security check.
#
#  submit_query - This routine submits a query to
#    the database and returns the results in an array
#    for each row returned.
#
############################################################
                #
                # $sc_db_lib_was_loaded is set to "yes"
                # to make sure that the db library
                # is not loaded more than once within
                # the web store script. The main 
                # web store script checks to see
                # if this variable is set before it
                # attempts to require this library.
                #
$sc_db_lib_was_loaded = "yes";

############################################################
# 
# subroutine: check_db_with_product_id
#   Usage:
#     $status = &check_db_with_product_id($product_id,
#                  *db_row);
#
#   Parameters:  
#     $product_id = product id in the cart to check
#     *db_row = @db_row passed by reference to
#        obtain the row that corresponds to the
#        product id.
#
#   Output:
#     $status = whether the product id is has been
#        found in the database. If it has not, then
#        we know right away that something went wrong.
#
#     @db_row is returned by reference to the calling
#        sub routine. It contains the row in the DB that
#        matches the product ID. This row can then be
#        checked by the Web Store to see if other items such
#        as price match the cart item.  Each element of
#        @db_row is a field in the database.
#
############################################################

sub check_db_with_product_id {
  local($product_id, *db_row) = @_;
  local($db_product_id);
                #
                # First we open the data file.
                # If the open fails. We call the
                # file open error routine in order
                # to log the error
                #
  open(DATAFILE, "$sc_data_file_path") ||
    &file_open_error("$sc_data_file_path",
      "Read Database",__FILE__,__LINE__);

                #
                # Each line in the data file
                # is read into $line variable.
                # 
                # Then, it is split into
                # fields which are placed in 
                # @db_rows.
                #
                # If it turns out that the 
                # product id matches the
                # product id in the database
                # row, the while loop will
                # stop, and the db_row will
                # contain the row matching
                # the product id.
                #
  while (($line = <DATAFILE>) &&
         ($product_id ne $db_product_id)) {
    @db_row = split(/\|/,$line);
    $db_product_id = $db_row[0];
  }

  close (DATAFILE);

                # return the result of the boolean expression

  return ($product_id eq $db_product_id);

} # End of check_db_with_product_id

############################################################
# 
# subroutine: submit_query
#   Usage:
#     ($status, $row_count) = &submit_query(*db_rows);
#
#   Parameters:  
#     *db_rows = an empty array is passed by reference
#       so that it can be filled with the contents of
#       the rows that satisfy the query.
#
#   Output:
#     $status = blank is no error. It contains an 
#       abbreviated name of the error that occured if
#       there was a problem with the query such as
#       "max_rows_exceeded".
#   
#     $row_count = amount of rows that satisfied query
#       even if the count exceeded the maximum allowed.
#       This row count will never actually exceed
#       1 above the row count in the flat file version
#       of this routine because it is inefficient to
#       keep reading a text file if we do not 
#       intend to present the user with the subsequent
#       information.
#
#     *db_rows = an array where each row is a row that
#       satisfied the results of the query. The rows 
#       stop being added to this array if $sc_max_rows
#       setup variable is exceeded.
#
#       Each row contains the fields in a PIPE delimited
#       form.
#
############################################################

sub submit_query
{
  local(*database_rows) = @_;
  local($status);
  local(@fields);
  local($row_count);
  local(@not_found_criteria);
  local($line); # Read line from database

                #
                # exact_match and case_sensitive
                # are special form variables
                # which alter the behavior of 
                # keyword searches (string data
                # type with the = operator).
                #
                # Normally keyword searches are
                # case insensitive and are not
                # exact match searches.
                #
  local($exact_match) = $form_data{'exact_match'};
  local($case_sensitive) = $form_data{'case_sensitive'};

                # We initialize row count to 0.
                #
  $row_count = 0;
 
                #
                # The first thing we need to do is
                # open the data file and then check to
                # see if there was an error doing this.
                #
  open(DATAFILE, "$sc_data_file_path") ||
    &file_open_error("$sc_data_file_path",
      "Read Database",__FILE__,__LINE__);

                #
                # If there was no error opening it,
                # then we read each line into $line
                # until the file ends or the row count
                # exceeds the maximum rows returned plus
                # 1.
                #        
  while(($line = <DATAFILE> ))# &&
        #($row_count < $sc_db_max_rows_returned + 1))
  {
    chop($line); # Chop off extraneous newline

                # Each field is split based on the pipe
                # delimiter.
    @fields = split(/\|/, $line);

                # First, we set not_found to zero
                # which indicates that we are assuming
                # the criteria was satisfied for the
                # row.
                # 
                # Then, for each criteria
                # specified in @sc_db_query_criteria,
                # we call a routine to apply the
                # criteria. If the criteria is 
                # not satisfied, it keeps returning
                # 1 which would increment $not_found.
                #
                # Thus, $not_found will end up being
                # the number of criteria that were
                # not found.  0 means success.
                #
    $not_found = 0;
    foreach $criteria (@sc_db_query_criteria)
    {  
      $not_found += &flatfile_apply_criteria(
	$exact_match,
	$case_sensitive,
	*fields,
	$criteria);
    }

                # If not found is 0, and
                # the row count has not exceeded
                # the amount of rows that we
                # promised to return,
                # the row is pushed into the
                # @db_rows array.
                #
    if (($not_found == 0))# && 
        #($row_count <= $sc_db_max_rows_returned))
    {
      push(@database_rows, join("\|", @fields));
    }
                #
                # We always want to increment row count even
                # if we exceeded the maximum amount of rows 
                # being returned.
                #
                # When not_found = 0, that means that the
                # criteria was satisfied for the row.

    if ($not_found == 0) {
      $row_count++;
    }
  } # End of while datafile has data

                # Finally, we close the datafile when
                # we are done with it.

  close (DATAFILE);

                # We passed database rows by reference so that
                # no extra copying of the array is needed when
                # we return the status.
                #
if ($row_count > $sc_db_max_rows_returned) {
    $status = "max_rows_exceeded";
} 

if ($row_count == 0) {
&PrintNoHitsBodyHTML;
exit;
} 


                # Finally, we return the status and
                # the row count.
                #
  return($status,$row_count);

} # End of submit query

############################################################
# 
# subroutine: flatfile_apply_criteria
#  Usage:
#      $status = &flatfile_apply_criteria(
#	$exact_match,
#	$case_sensitive,
#	*fields,
#	$criteria);
#
#   Parameters:
#      $exact_match = on if the user
#        selected to perform exact whole word matches
#        on the database strings
#      $case_sensitive = on if the user 
#        selected to perform case sensitive matches
#        on the database strings.
#      *fields is a reference to the array of fields 
#       in the current database row that we are
#       searching.
#      $criteria is the current criteria that we
#       are applying to the database row. The criteria
#       is gathered from the @sc_query_criteria array
#       from the setup file.
#
#   Output:
#     status indicating whether the criteria was
#     not found or not. If it is not found, a 1
#     is returned. If it is, then a 0 is returned.
# 
############################################################

sub flatfile_apply_criteria
{
  local($exact_match, $case_sensitive,
      *fields, $criteria) = @_;
                # format for the $criteria line
                # the criteria is pipe delimited and
                # consists of the form variable name
                # that the criteria will be matched
                # against, the fields in the database
                # which will be matched against,
                # the operator to use in comparison,
                # and finally, the data type that the
                # operator should use in the comparison
                # (date, number, or string comparison).
                # 
  local($c_name, $c_fields, $c_op, $c_type);
                # array of c_fields
  local(@criteria_fields);
                # flag for whether we found something
  local($not_found);
                # Value for form field
  local($form_value);
                # Value for db field
  local($db_value);
                # Date Comparison Place holders
  local($month, $year, $day);
  local($db_date, $form_date);
                # Place marker for current database
                # field index we are looking at 
  local($db_index);
                # list of words in a string for matching
  local(@word_list);

                # Get criteria information
  ($c_name, $c_fields, $c_op, $c_type) = 
     split(/\|/, $criteria);

                # The criteria can match more than ONE
                # field in the database! Thus, we get the
                # index values of the fields in each row
                # of the database that the form variable
                # will be compared against.
                # 
                # Remember, fields and lists in perl
                # start counting at 0.
                # 
  @criteria_fields = split(/,/,$c_fields);

                # We get the value of the form.
                # 
  $form_value = $form_data{$c_name};

                # There are three cases of comparison
                # that will return a value.
                # 
                # Case 1: The form field for the criteria
                # was not filled out, so the match is
                # considered a success.
                # 
                # Remember, if the user does not 
                # enter a keyword, we want the search
                # to be open-ended. Only restrict the
                # search if the user chooses to enter
                # a search word into the appropriate 
                # query field.

  if ($form_value eq "")
  {
    return 0;
  }

                # Case 2: The data type is a
                # number or a date. OR if
                # the data type is a string
                # and the operator is NOT
                # =. So we match against the
                # operator directly based on the
                # data type. (A string,= match
                # is considered a separate case
                # below).
                # 

  if (($c_type =~ /date/i) ||
     ($c_type =~ /number/i) ||
     ($c_op ne "="))
  {
                # First, we set not_found to yes. 
                # We assume that the data did not
                # match. If any fields match
                # the data submitted by the user,
                # then, we will set not_found to no
                # later on.

    $not_found = "yes";

                # Go through each database field
                # specified in @criteria_fields
                # and compare it
    foreach $db_index (@criteria_fields)
    {
                # Get the value of the field in the 
                # database that corresponds to the
                # index number.

      $db_value = $fields[$db_index];

                # If the type of data comparison
                # we are doing is based on a date compare,
                # then we need to convert the date
                # into the format YYYYMMDD instead of 
                # MM/DD/YY. This is because YYYYMMDD is
                # easier to compare directly. A date
                # in the form YYYYMMDD can use the normal
                # >,<,etc.. numerical operators to
                # compare against.
                # 
                # 2 digit years are converted to 4
                # digit years so that this script
                # will still comply with the year 2000
                # problem.
                # 
      if ($c_type =~ /date/i) 
      {
        ($month, $day, $year) =
          split(/\//, $db_value);
        $month = "0" . $month
          if (length($month) < 2);
        $day = "0" . $day
          if (length($day) < 2);
        if ($year > 50 && $year < 1900) {
          $year += 1900;
        }
        if ($year < 1900) {
          $year += 2000;
        }
        $db_date = $year . $month . $day;

        ($month, $day, $year) =
          split(/\//, $form_value);
        $month = "0" . $month
          if (length($month) < 2);
        $day = "0" . $day
          if (length($day) < 2);
        if ($year > 50 && $year < 1900) {
          $year += 1900;
        }
        if ($year < 1900) {
          $year += 2000;
        }
        $form_date = $year . $month . $day;

                # If any of the date comparisons match
                # then a 0 is returned to let the submit_query
                # routine know that a match was found.
        if ($c_op eq ">") {
          return 0 if ($form_date > $db_date); }
        if ($c_op eq "<") {
          return 0 if ($form_date < $db_date); }
        if ($c_op eq ">=") {
          return 0 if ($form_date >= $db_date); }
        if ($c_op eq "<=") {
          return 0 if ($form_date <= $db_date); }
        if ($c_op eq "!=") {
          return 0 if ($form_date != $db_date); }
        if ($c_op eq "=") {
          return 0 if ($form_date == $db_date); }
                # 
                # If the data type is a number
                # then we perform normal number
                # comparisons in Perl.

      } elsif ($c_type =~ /number/i) {
        if ($c_op eq ">") {
          return 0 if ($form_value > $db_value); }
        if ($c_op eq "<") {
          return 0 if ($form_value < $db_value); }
        if ($c_op eq ">=") {
          return 0 if ($form_value >= $db_value); }
        if ($c_op eq "<=") {
          return 0 if ($form_value <= $db_value); }
        if ($c_op eq "!=") {
          return 0 if ($form_value != $db_value); }
        if ($c_op eq "=") {
          return 0 if ($form_value == $db_value); }

                # If the data type is a string
                # then we take the operators and
                # apply the corresponding Perl string
                # operation. For example, != is ne,
                # > is gt, etc.
                # 
      } else { # $c_type is a string
        if ($c_op eq ">") {
          return 0 if ($form_value gt $db_value); }
        if ($c_op eq "<") {
          return 0 if ($form_value lt $db_value); }
        if ($c_op eq ">=") {
          return 0 if ($form_value ge $db_value); }
        if ($c_op eq "<=") {
          return 0 if ($form_value le $db_value); }
        if ($c_op eq "!=") {
          return 0 if ($form_value ne $db_value); }
      }    
    } # End of foreach $form_field
    
  } else { # End of case 2, Begin Case 3
                # Case 3: The data type is a string and
                #         the operator is =. This is
                #         more complex because we need
                #         to check whether our string
                #         matching matches whole words
                #         or is case sensitive.
                # 
                #         In otherwords, this is a more
                #         "fuzzy" search.
                # 
                # arguments: $exact_match, $case_sensitive
                #            affect the search
                # In addition, the form_value will be split
                # on whitespace so that white-space separated
                # words will be searched separately.
                # 
                # Take the words that were entered and parse them into
                # an array of words based on word boundary (\s+ splits on
                # whitespace) 

    @word_list = split(/\s+/,$form_value);

                # Again, we go through the fields in the
                # database that are checked for this 
                # particular criteria
                # definition.

    foreach $db_index (@criteria_fields)
    {
                # Obtain the value of the database field
                # we are currently matching against.

      $db_value = $fields[$db_index];
      $not_found = "yes";
                # $match_word is a place marker for the words
                # we are going to be looking for in the database row
                # $x is a place marker inside the for loops.
      local($match_word) = "";
      local($x) = "";

                ####### START OF KEYWORD SEARCH #####
                # 
                # This routine is the same as the HTML
                # Search Engine find_keywords subroutine
                #
                # Basically, the deal is that as the
                # words get found, they get removed
                # from the @word_list array.
                # 
                # When the array is empty, we know
                # that all the keywords were found.
                # 
                # We will later celebrate this
                # event by returning the fact that
                # a match was found for this criteria.
                #  
      if ($case_sensitive eq "on") {
          if ($exact_match eq "on") {
              for ($x = @word_list; $x > 0; $x--) {
            # \b matches on word boundary
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /\b$match_word\b/) {
                      splice(@word_list,$x - 1, 1);
                  } # End of If
              } # End of For Loop
          } else {
              for ($x = @word_list; $x > 0; $x--) {
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /$match_word/) {
                      splice(@word_list,$x - 1, 1);
                  } # End of If
              } # End of For Loop
          } # End of ELSE
      } else {
          if ($exact_match eq "on") {
              for ($x = @word_list; $x > 0; $x--) {
      # \b matches on word boundary
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /\b$match_word\b/i) {
                      splice(@word_list,$x - 1, 1);
                  } # End of If  
              } # End of For Loop
          } else {
              for ($x = @word_list; $x > 0; $x--) {
                  $match_word = $word_list[$x - 1];
                  if ($db_value =~ /$match_word/i) {
                      splice(@word_list,$x - 1, 1);
                  } # End of If
              } # End of For Loop
          } # End of ELSE
      }

                ####### END OF KEYWORD SEARCH #######

    } # End of foreach $db_index

                # If there is nothing left in the word_list
                # we want to say that we found the word
                # in the $db_value. Thus, $not_found is set to
                # "no" in this case.
    if (@word_list < 1) 
    {
      $not_found = "no";
    }

  } # End of case 3

                # If not_found is still equal to yes,
                # we return a 1, indicating that the
                # criteria was not satisfied
                # 
                # If not_found is not yes, then 
                # we return that a successful match
                # was found (0).
                # 
  if ($not_found eq "yes")
  {
    return 1;
  } else {
    return 0;
  }
} # End of flatfile_apply_criteria

1; # Returns a true value because it is a library file
