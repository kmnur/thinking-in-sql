<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Top N Records Per Group - Thinking in SQL</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 800px; margin: 2rem auto; padding: 1rem; line-height: 1.6; }
    pre { background: #f4f4f4; padding: 1em; overflow-x: auto; }
    code { font-family: monospace; }
    table { border-collapse: collapse; width: 100%; margin: 1rem 0; }
    th, td { border: 1px solid #ccc; padding: 0.5rem; text-align: left; }
    blockquote { border-left: 4px solid #ccc; padding-left: 1em; color: #555; }
    h1, h2, h3 { color: #333; }
    a { color: #007acc; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
<h1>Top N Records Per Group in SQL</h1>

<p><strong>By Kazi Mohammad Ali Nur (Romel)</strong></p>

<blockquote>
  <p>🧠 <strong>Inspired by my answer to this Stack Overflow question:</strong><br />
  <a href="https://stackoverflow.com/questions/67475198/select-2-products-per-city-with-most-counts-in-postgresql/67475289#67475289">Select 2 products per city with most counts in PostgreSQL</a>  </p>
  
  <p>In the original question, the user asked how to retrieve <strong>two products per city</strong> with the highest total count using PostgreSQL.</p>
  
  <p>In my answer, I’ve used <code>ROW_NUMBER()</code> in combination with a <strong>Common Table Expression (CTE)</strong> to extract the top N records per group.</p>
  
  <p>This approach is clean, modular, and supported across most modern SQL engines. The <code>ROW_NUMBER()</code> function allows us to rank each row within a partition (like rows per city), and the CTE helps us separate the ranking logic from the filtering logic.</p>
  
  <p>If you're new to either concept, don't worry — we’ll break down both at the bottom of this tutorial.</p>
</blockquote>

<hr />

<blockquote>
  <p>In this tutorial, we’ll use a CTE to isolate the ranked rows before filtering out the top N per group.</p>
</blockquote>

<hr />

<h2>✅ Solutions by Database</h2>

<h3>🐘 PostgreSQL</h3>

<p>In this solution, I’ve used <code>ROW_NUMBER()</code> to rank products within each city based on their count — from highest to lowest. The <code>PARTITION BY the_city</code> clause ensures that the ranking restarts for every city, while <code>ORDER BY count(*) DESC</code> gives us the most frequent products first.</p>

<p>The ranking logic is wrapped inside a Common Table Expression (CTE) named <code>city_products</code>, which simplifies the final selection: we just filter where <code>rn &lt;= 2</code> to get the top 2 products per city.</p>

<p>This approach is elegant, readable, and performs well in most SQL engines that support window functions.</p>

<div class="codehilite">
<pre><span></span><code><span class="k">WITH</span><span class="w"> </span><span class="n">city_products</span><span class="w"> </span><span class="k">AS</span><span class="w"> </span><span class="p">(</span>
<span class="w">  </span><span class="k">SELECT</span>
<span class="w">    </span><span class="n">the_city</span><span class="p">,</span>
<span class="w">    </span><span class="n">the_product</span><span class="p">,</span>
<span class="w">    </span><span class="k">COUNT</span><span class="p">(</span><span class="o">*</span><span class="p">)</span><span class="w"> </span><span class="k">AS</span><span class="w"> </span><span class="n">product_count</span><span class="p">,</span>
<span class="w">    </span><span class="n">ROW_NUMBER</span><span class="p">()</span><span class="w"> </span><span class="n">OVER</span><span class="w"> </span><span class="p">(</span><span class="n">PARTITION</span><span class="w"> </span><span class="k">BY</span><span class="w"> </span><span class="n">the_city</span><span class="w"> </span><span class="k">ORDER</span><span class="w"> </span><span class="k">BY</span><span class="w"> </span><span class="k">COUNT</span><span class="p">(</span><span class="o">*</span><span class="p">)</span><span class="w"> </span><span class="k">DESC</span><span class="p">)</span><span class="w"> </span><span class="k">AS</span><span class="w"> </span><span class="n">rn</span>
<span class="w">  </span><span class="k">FROM</span><span class="w"> </span><span class="n">my_table</span>
<span class="w">  </span><span class="k">GROUP</span><span class="w"> </span><span class="k">BY</span><span class="w"> </span><span class="n">the_city</span><span class="p">,</span><span class="w"> </span><span class="n">the_product</span>
<span class="p">)</span>
<span class="k">SELECT</span><span class="w"> </span><span class="n">the_city</span><span class="p">,</span><span class="w"> </span><span class="n">the_product</span><span class="p">,</span><span class="w"> </span><span class="n">product_count</span>
<span class="k">FROM</span><span class="w"> </span><span class="n">city_products</span>
<span class="k">WHERE</span><span class="w"> </span><span class="n">rn</span><span class="w"> </span><span class="o">&lt;=</span><span class="w"> </span><span class="mi">2</span><span class="p">;</span>
</code></pre>
</div>

<p><strong>Sample Output:</strong></p>

<table>
<thead>
<tr>
  <th>the_city</th>
  <th>the_product</th>
  <th>product_count</th>
</tr>
</thead>
<tbody>
<tr>
  <td>EVORA</td>
  <td>D</td>
  <td>4</td>
</tr>
<tr>
  <td>EVORA</td>
  <td>B</td>
  <td>2</td>
</tr>
<tr>
  <td>LISBO</td>
  <td>A</td>
  <td>5</td>
</tr>
<tr>
  <td>LISBO</td>
  <td>B</td>
  <td>2</td>
</tr>
<tr>
  <td>PORTO</td>
  <td>C</td>
  <td>3</td>
</tr>
<tr>
  <td>PORTO</td>
  <td>B</td>
  <td>2</td>
</tr>
</tbody>
</table>

<p>👉 <a href="https://dbfiddle.uk/ZlUjxoMm">Try it live on DB Fiddle</a></p>

<hr />

<h3>🪟 SQL Server</h3>

<p>👉 <a href="https://dbfiddle.uk/rsq8MqN8">Try it live on DB Fiddle</a></p>

<hr />

<h3>🟠 Oracle (12c+)</h3>

<p>👉 <a href="https://dbfiddle.uk/Q-1c5-R-">Try it live on DB Fiddle</a></p>

<hr />

<h3>🟡 MySQL 8+</h3>

<p>👉 <a href="https://dbfiddle.uk/MmB_1WEk">Try it live on DB Fiddle</a></p>

<hr />

<h2>🧠 What is ROW_NUMBER()?</h2>

<p><code>ROW_NUMBER()</code> is a <strong>window function</strong> that assigns a unique, sequential number to each row within a result set, based on a specified sort order.</p>

<p>You can use <code>PARTITION BY</code> to reset the numbering <strong>within each group</strong>, and <code>ORDER BY</code> to define how rows are sorted before numbers are assigned.</p>

<h3>📘 Example:</h3>

<p>Suppose you want to rank students by their score:</p>

<div class="codehilite">
<pre><span></span><code><span class="k">SELECT</span><span class="w"> </span><span class="n">student</span><span class="p">,</span><span class="w"> </span><span class="n">score</span><span class="p">,</span>
<span class="w">  </span><span class="n">ROW_NUMBER</span><span class="p">()</span><span class="w"> </span><span class="n">OVER</span><span class="w"> </span><span class="p">(</span><span class="k">ORDER</span><span class="w"> </span><span class="k">BY</span><span class="w"> </span><span class="n">score</span><span class="w"> </span><span class="k">DESC</span><span class="p">)</span><span class="w"> </span><span class="k">AS</span><span class="w"> </span><span class="n">rank</span>
<span class="k">FROM</span><span class="w"> </span><span class="n">results</span><span class="p">;</span>
</code></pre>
</div>

<p>This produces:</p>

<table>
<thead>
<tr>
  <th>student</th>
  <th>score</th>
  <th>rank</th>
</tr>
</thead>
<tbody>
<tr>
  <td>Alice</td>
  <td>95</td>
  <td>1</td>
</tr>
<tr>
  <td>Bob</td>
  <td>90</td>
  <td>2</td>
</tr>
<tr>
  <td>Carol</td>
  <td>85</td>
  <td>3</td>
</tr>
</tbody>
</table>

<p>If you add <code>PARTITION BY class</code>, the numbering restarts for each class.</p>

<blockquote>
  <p>In our solution, we'll use <code>ROW_NUMBER()</code> to identify the <strong>top N products per city</strong>, based on total quantity sold.</p>
</blockquote>

<hr />

<h2>📘 What is a CTE?</h2>

<p>A <strong>CTE (Common Table Expression)</strong> is a temporary result set defined using the <code>WITH</code> keyword. It allows you to write <strong>complex queries in a readable, modular way</strong>, especially when working with window functions like <code>ROW_NUMBER()</code>.</p>

<p>Think of it like a named subquery that you can reference as if it's a table:</p>

<div class="codehilite">
<pre><span></span><code><span class="k">WITH</span><span class="w"> </span><span class="n">ranked_sales</span><span class="w"> </span><span class="k">AS</span><span class="w"> </span><span class="p">(</span>
<span class="w">  </span><span class="k">SELECT</span><span class="w"> </span><span class="p">...</span>
<span class="p">)</span>
<span class="k">SELECT</span><span class="w"> </span><span class="p">...</span>
<span class="k">FROM</span><span class="w"> </span><span class="n">ranked_sales</span>
<span class="k">WHERE</span><span class="w"> </span><span class="p">...</span>
</code></pre>
</div>

<hr />

<h2>📦 Downloadable SQL Scripts by Database</h2>

<ul>
<li>🐘 <a href="../sql/top-n-per-group/postgres.sql">PostgreSQL</a></li>
<li>🪟 <a href="../sql/top-n-per-group/sql-server.sql">SQL Server</a></li>
<li>🟠 <a href="../sql/top-n-per-group/oracle.sql">Oracle</a></li>
<li>🟡 <a href="../sql/top-n-per-group/mysql-8plus.sql">MySQL 8+</a></li>
<li>⚠️ <a href="../sql/top-n-per-group/mysql-5.7.sql">MySQL 5.7 or earlier</a></li>
</ul>

</body>
</html>
