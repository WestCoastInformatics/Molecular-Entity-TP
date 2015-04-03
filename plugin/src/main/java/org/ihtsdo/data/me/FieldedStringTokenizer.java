package org.ihtsdo.data.me;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

/**
 * Breaks character deliminted strings into constituent fields. Unlike the
 * {@link java.util.StringTokenizer} it recognizes empty tokens. For example,
 * using a pipe character '|' as a delimiter, it would tokenize the string
 * "a||b" into three tokens "a", "", "b". Following is an example of how to use
 * this class.
 *
 * <pre>
 * FieldedStringTokenizer tokenizer = new FieldedStringTokenizer(&quot;a|b||c&quot;, &quot;|&quot;);
 * int i = 1;
 * while (tokenizer.hasMoreTokens()) {
 *   System.out.println(&quot;Token &quot; + i + &quot; is: &quot; + tokenizer.nextToken());
 * }
 * </pre>
 *
 * This class can also be used in a static way to split a line on a particular
 * character delmiter and have a <code>String[]</code> passed back. For example,
 *
 * <pre>
 * String[] tokens = FieldedStringTokenizer.split(&quot;a|b|c|d&quot;, &quot;|&quot;);
 * </pre>
 *
 * This code will produce the string array <code>{"a","b","c","d"}</code>.
 *
 * @author MEME Group
 */
public class FieldedStringTokenizer implements Enumeration<Object> {

  //
  // Fields
  //

  /**  The tokens. */
  private ArrayList<String> tokens = null;

  /**  The ct. */
  private int ct = 0;

  //
  // Constructors
  //

  /**
   * Instantiates a {@link FieldedStringTokenizer} for the specified string. The
   * characters in the <code>delim</code> argument are the delimiters for
   * separating tokens. Delimiter characters themselves will not be treated as
   * tokens. This tokenizer will return null tokens for adjacent delimiters.
   * @param str a {@link String} to be tokenized
   * @param delim a {@link String} containing delimiter characters
   */
  public FieldedStringTokenizer(String str, String delim) {
    //
    // Use split to get tokens
    //
    String[] token_array = split(str, delim);

    //
    // Add tokens to arraylist
    //
    tokens = new ArrayList<String>(token_array.length + 1);
    for (int i = 0; i < token_array.length; i++) {
      tokens.add(token_array[i]);
    }
  }

  //
  // Static Method
  //

  /**
   * Splits a line on delimiter characters and returns a {@link String}
   * <code>[]</code> of the tokens.
   * @param line a {@link String} to be split
   * @param delim a {@link String} containing delimiter characters
   * @return a <code>String []</code> containing tokens from the string
   */
  public static String[] split(String line, String delim) {

    //
    // Create list to contain tokens
    //
    final List<String> tokens = new ArrayList<String>(20);

    //
    // If no data, return empty array
    //
    if (line == null || line.length() == 0) {
      return new String[0];
    }

    //
    // Parse out words
    //
    int old_index = 0;
    int new_index = 0;
    do {

      //
      // Find next index of any delim character
      //
      new_index = -1;
      for (int i = old_index; i < line.length(); i++) {
        if (delim.indexOf(line.charAt(i)) != -1) {
          new_index = i;
          break;
        }
      }

      //
      // Get next token (or last token if new_index=-1)
      //
      if (new_index == -1) {

        //
        // If the line ends with a delimiter, assume there is no
        // null token at the end
        //
        if (old_index < line.length()) {
          tokens.add(line.substring(old_index));

        }
      } else {
        tokens.add(line.substring(old_index, new_index));
        old_index = new_index + 1;
      }

    } while (new_index != -1);

    return tokens.toArray(new String[0]);
  }

  /**
   * Splits a line on delimiter characters when the number of fields is known in
   * advance and returns a string array of the tokens.
   * @param line a {@link String} to be split
   * @param delim a {@link String} containing delimiter characters
   * @param field_ct the number of fields in the line to be split.
   * @return a <code>String []</code> containing tokens from the string
   */
  public static String[] split(final String line, final String delim,
    final int field_ct) {
    // return line.split("[" + delim + "]", field_ct);
    //
    // Prep array
    //
    String[] tokens = new String[field_ct];

    //
    // Return empty array if line is blank
    //
    if (line == null || line.length() == 0) {
      return new String[0];
    }

    //
    // Parse out words
    //
    int ct = 0;
    int old_index = 0;
    int new_index = 0;
    int i = 0;
    do {

      //
      // Find next index of any delim character
      //
      new_index = -1;
      for (i = old_index; i < line.length(); i++) {
        if (delim.indexOf(line.charAt(i)) != -1) {
          new_index = i;
          break;
        }
      }

      //
      // Get next token (or last token if new_index=-1)
      //
      if (new_index == -1) {

        //
        // If the line ends with a delimiter, assume there is no
        // null token at the end
        //
        if (old_index < line.length()) {
          tokens[ct] = line.substring(old_index);
        }
      } else {
        tokens[ct++] = line.substring(old_index, new_index);
        old_index = new_index + 1;
      }

    } while (new_index != -1);

    return tokens;

  }

  /**
   * Splits a line on delimiter characters when the number of fields is known in
   * advance and populates the specified String[].
   * @param line a {@link String} to be split
   * @param delim a {@link String} containing delimiter characters
   * @param field_ct <code>int</code> indicates the max number of fields to
   *          split
   * @param tokens a {@link String}[] of the right number of tokens.
   */
  public static void split(final String line, final String delim, int field_ct,
    final String[] tokens) {
    // return line.split("[" + delim + "]", field_ct);

    //
    // Return empty array if line is blank
    //
    if (line == null || line.length() == 0) {
      return;
    }

    //
    // Parse out words
    //
    int ct = 0;
    int old_index = 0;
    int new_index = 0;
    int i = 0;
    final int len = line.length();
    do {

      //
      // Find next index of any delim character
      //
      new_index = -1;
      for (i = old_index; i < len; i++) {
        if (delim.indexOf(line.charAt(i)) != -1) {
          new_index = i;
          break;
        }
      }

      //
      // Get next token (or last token if new_index=-1)
      //
      if (new_index == -1) {

        //
        // If the line ends with a delimiter, assume there is no
        // null token at the end
        //
        if (old_index < len) {
          tokens[ct] = line.substring(old_index);
        }
      } else {
        tokens[ct++] = line.substring(old_index, new_index);
        old_index = new_index + 1;
      }

    } while (new_index != -1);

    // return tokens;

  }

  //
  // Methods
  //

  /**
   * Calculates the number of times that this tokenizer's {@link #nextToken()}
   * method can be called before it generates an exception. The current position
   * is not advanced.
   * @return an <code>int</code> count of the number of tokens
   */
  public int countTokens() {
    return tokens.size() - ct;
  }

  /**
   * Returns the same value as the {@link #hasMoreTokens()} method. It exists so
   * that this class can implement the {@link Enumeration} interface.
   * @return <code>true</code> if there are more tokens; <code>false</code>
   *         otherwise
   */
  @Override
  public boolean hasMoreElements() {
    return hasMoreTokens();
  }

  /**
   * Tests if there are more tokens available from this tokenizer's string. If
   * this method returns true, then a subsequent call to {@link #nextToken()}
   * will successfully return a token.
   * @return <code>true</code> if there are more tokens; <code>false</code>
   *         otherwise
   */
  public boolean hasMoreTokens() {
    return ((tokens.size() - ct) > 0);
  }

  /**
   * Returns the same value as the {@link #nextToken()} method, except that its
   * declared return value is {@link Object} rather than {@link String}. It
   * exists so that this class can implement the {@link Enumeration} interface.
   * @return An object {@link String} representation of the next token
   */
  @Override
  public Object nextElement() {
    return nextToken();
  }

  /**
   * Returns the next token in this tokenizer's string.
   * @return the next token in this tokeinzer's string
   */
  public String nextToken() {
    String token = tokens.get(ct++);
    return token;
  }

  /**
   * Self-qa test.
   * @param args a {@link String}<code>[]</code> containing a string to split
   *          and a delimiter set
   */
  public static void main(String[] args) {
    System.out.println("split test: " + args[0] + ", " + args[1]);
    String[] s = FieldedStringTokenizer.split(args[0], args[1]);
    for (int i = 0; i < s.length; i++) {
      System.out.println("Token " + i + ": " + s[i]);

    }
    System.out.println("tokenizer test: " + args[0] + ", " + args[1]);
    FieldedStringTokenizer t = new FieldedStringTokenizer(args[0], args[1]);
    int i = 0;
    while (t.hasMoreTokens()) {
      System.out.println("Token " + i++ + ": " + t.nextToken());
    }

  }
}
