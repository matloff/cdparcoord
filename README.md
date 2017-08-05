# cdparcoord:  Categorical and Discrete Parallel Coordinates

# Table of Contents
1. [Quickstart](#quickstart)
2. [Overview](#overview)
3. [Key Functions](#key-functions)
4. [Warnings](#warnings)
5. [Authors](#authors)

The *parallel coordinates* approach is a popular method for graphing
multivariate data.  However, for large data sets, the method suffers
from the ["black screen problem"](#black-screen-problem) -- the jumble of lines
fills the screen and it is difficult if not impossible to discern any
relationships in the data.  

Consider the dataset **mlb**, consisting of data on Major League
Baseball players, courtesy of the UCLA Stat Dept.

```R
data(mlb)
# extract height, weight, age
m <- mlb[,4:6]
# ordinary parallel coordinates 
library(MASS) 
parcoord(m) 
```

<img src="vignettes/MLB1.png" alt="n1" width="500"/>

Each line in the graph represents one player, connecting his height,
weight and age.  But since there are so many lines (actually only about
1000), the graph is useless.


Our solution is to graph only the most frequent lines.  Our
**freqparcoord** package, aimed at continuous variables, with line
frequency defined in terms of estimated multivariate density.  The
current package, **cdparcoord**, covers the case of categorical
variables, with frequency defined as actual tuple count.  (In a mixed
continuous-categorical setting, the continuous variables are
discretized.)

# Quickstart

Here we give a quick view of the package operations.
It is assumed that the user has already executed

```R
library(cdparcoord)
```

##### Example

(UNDER REVISION.)

This example involves data from the 2000 U.S. census, on programmers and
engineers in Silicon Valley, a dataset included with the package.

Suppose our interest is exploring whether women encounter wage
discrimination.  Of course we won't settle such a complex question here,
but it will serve as a good example of the use of the package.

We first load the data, and select some of the columns for display/ We
also remove same very high wages (at least in the context of the year
2000) to make the display easier.

```R
data(prgeng)
pe <- prgeng[,c(1,3,5,7:9)]
pe25 <- pe[pe$wageinc < 250000,]
```

As mentioned, a key feature of the package is discretization of
continuous variables, so that tuple frequency counts have meaning. We
will do this via the package's **discretize()** function, which we will
apply to the numeric variables.

However, in this particular data set, there are variables that seem
numeric but are in essence factors, as the are codes.  For the **educ**
variable, for instance, 14 codes a master's degree. (A code list is
available at the [Census Bureau
site](https://www.census.gov/prod/cen2000/doc/pums.pdfr).)

So, let's change the coded variables to factors, and then discretize:

```R
pe25 <- makeFactor(pe25,c('educ','occ','sex'))
pe25disc <- discretize(pe25)  # using default options
```

Now display:

```R
discparcoord(pe25disc,k=150)  # default options again, other than k
```

Here we are having **cdparcoord** display the 150 most frequent tuple
patterns. The result is

<img src="vignettes/PE1.png" alt="n1" width="800"/>

For example, there is a blue line corresponding to the tuple,

(age=29,educ=13,occ=102,sex=1,wageinc=38000,wkswrkd=52)

(The line actually splits into two at the **wageinc** variable.)  The
frequencies are color-coded accoring to the legend at the right. So
the above tuple occurred something like 180 times in the data.

What about the difference between males and females (coded 1 and 2)?
Though there is consider range in wages for the two groups, visually 
there seems to be some suggestion that the women's wages tend to be
lower.

However, if this is the case, it may be explained by differences between
the two groups in other variables.  For instance, do women tend to be in
lower-paying occupations?  To investigate that, let's move the **occ**
column to be adjacent to **wageinc**.

This is accomplished by a mouse operation that is provided by **plotly**,
the graphical package on top of which **cdparcoord** is built.
Specifically, we can use the mouse to drag the **occ** label to the
right, releasing the mouse when the column reaches near the **wageinc**
column.  The result is

<img src="vignettes/PE2.png" alt="n1" width="800"/>

Again, there is a range for each occupation. However, looking at the
more-frequent lines, the blue and yellow ones, occupations 141 and 102
seem to pay more.  (More on this point below.)  And if so, that seems to
be bad news for the women, as there appears to a be slight tendency for
the women to be more concentrated in occupations 101 and 100.

To obtain a somehwat finer look, we can use another feature supplied by
**plotly**, a form of *brushing*. Here we highlight the women's lines by
using the mouse to drag the top of the **sex** column down slightly.
This causes the men's lines to go to light gray, while the women's lines
stay in color:

<img src="vignettes/PE3.png" alt="n1" width="800"/>

Now it really does appear that there is some tendency for the women to
be working in the less lucrative occupations.

Multiple columns can be brushed together. Brushing is indicated by a
small coloring of a portion of the line.  To turn off brushing, click
and drag on an uncolored portion.

# Example

We return to the baseball, and show a more advanced usage of
**discretize()**.  The dataset is probably too small to discretize --
some frequencies of interesting tuples will be very small -- but it is a
good example of usage of lists in **discretize()**. 

```R
inp1 <- list("name" = "Height",
             "partitions"=3,
             "labels"=c("short", "med", "tall"))
inp2 <- list("name" = "Weight",
             "partitions"=3,
             "labels"=c("light", "med", "heavy"))
inp3 <- list("name" = "Age",
             "partitions"=2,
             "labels"=c("young", "old"))
discreteinput <- list(inp1, inp2, inp3)
discretizedmlb <- discretize(m, discreteinput)
discparcoord(discretizedmlb, name="MLB", k=100)

```

<img src="vignettes/MLB2.png" alt="n1" width="800"/>


### Accounting for NA Values

(EXPERIMENTAL)

R and R packages typically leave out any rows with NA
values. Unfortunately for data sets with high NA counts, this may have
drastic effects, such as low counts and possible bias. 
[`cdparcoord`](https://github.com/matloff/cdparcoord) addresses this
issue by allowing these rows to partially contribute to overall counts. 

# Key Functions

#### `discparcoord()`
The main function is `discparcoord()`, which may optionally be used with `discretize()`.
`discparcoord()` accounts for partial values and drawing.

#### `discretize()`
`discparcoord()` may optionally be used with `discretize()`.

`discretize` takes a dataset and a list of lists. It discretizes the
dataset's values such that `plot()` may chart categorical variables.
The inner list should contain the following variables: `int partitions`,
`string vector labels`, `vector lower bounds`, `vector upper bounds`.
The last three are optional.

#### `discparcoord()` details

Encompassed in discparcoord, we provide 3 key functions -- `partialNA()`
`grpcategory()`, and `interactivedraw()`.

1. The call `partialNA(dataset,n)` inputs a dataset and returns a new
   dataset consisting of the **n** most frequent patterns with an added
   column - the frequency of each column.  This dataset contains no NA
   values, as all of the columns previously with NA values have now been
   eliminated. 

   By default, `partialNA` returns the 5 most significant tuples.

2. The `grpcategory` option allows you to create multiple plots, one for
   each category. If a field has 4 possible values, then
   `discparcoord()` with the `grpcategory` option will create a plot for
   each category, where each plot has the specific category's
   attributes.

   For example, if a field "Weight "has "Heavyweight" and "Lightweight",
   then this will create one plot where all tuples are heavyweights,
   then one more where where all tuples are lightweights.

3. `interactivedraw()` takes a dataset and draws a parallel coordinates plot 
   that opens in your browser. It has movable columns, brushing, and the ability
   to save your plots. You can also choose to toggle labels on and off. 
   For more information, type `?interactivedraw` into the console.

# Tips

Like any exploratory graphical tool, **cdparcoord** is best used by
trying various parameter values.

1. By default, `partialNA()` returns the five most frequent
   correlations. If there is low/no correlation between variables, then
   this may be misleading.

2. Due to the limited size of screens compared to the number of
   variables in many data sets, we recommend subsetting input data to
   only include relevant variables prior to using the package.

3. Sometimes labels greatly hinder the visibility and clarity of the
   plot. This can be circumvented by opting to remove labels in plot.

4. Categorical data is currently scaled by 1, starting from 1. When
   placed on the same axis as numerical data with high values (ex:
   100+), it can be difficult to differentiate between categories when
   used with `draw()`. This does not occur with `interactivedraw()`.

# Authors

Norm Matloff, Harrison Nguyen, Vincent Yang
