# cdparcoord:  Categorical and Discrete Parallel Coordinates

# Table of Contents
1. [Quickstart](#quickstart)
2. [Overview](#overview)
3. [Key Functions](#key-functions)
4. [Tips](#tips)
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
[**freqparcoord**
package](https://cran.r-project.org/web/packages/freqparcoord/index.html),
aimed at continuous variables, with line frequency defined in terms of
estimated multivariate density.  The current package,
[**cdparcoord**](https://github.com/matloff/cdparcoord), covers the case
of categorical variables, with frequency defined as actual tuple count.
(In a mixed continuous-categorical setting, the continuous variables are
discretized.)

# Quickstart

Here we give a quick view of the package operations.
It is assumed that the user has already executed

```R
library(cdparcoord)
```

##### Example

This example involves data from the 2000 U.S. census on programmers and
engineers in Silicon Valley, a dataset included with the package.

Suppose our interest is exploring whether women encounter wage
discrimination.  Of course we won't settle such a complex question here,
but it will serve as a good example of the use of the package.

We first load the data, and select some of the columns for display. We
also remove some very high wages (at least in the context of the year
2000) to make the display easier.

```R
data(prgeng)
pe <- prgeng[,c(1,3,5,7:9)]
pe25 <- pe[pe$wageinc < 250000,]
```

The resulting data has just under 20,000 rows.

As mentioned, a key feature of the package is discretization of
continuous variables, so that tuple frequency counts have meaning. We
will do this via the package's **discretize()** function, which we will
apply to the numeric variables.

However, in this particular data set, there are variables that seem
numeric but are in essence factors, as they are codes.  For the **educ**
variable, for instance, the number 14 codes a master's degree. (A code
list is available at the [Census Bureau
site](https://www.census.gov/prod/cen2000/doc/pums.pdfr).)

So, let's change the coded variables to factors, and then discretize:

```R
pe25 <- makeFactor(pe25,c('educ','occ','sex'))
pe25disc <- discretize(pe25,nlevels=5)  
```

Each of the numeric variables here is discretized into 5 levels.

Now display:

```R
discparcoord(pe25disc,k=150)  # default options again, other than k
```

Here we are having **cdparcoord** display the 150 most frequent tuple
patterns. The result is

<img src="vignettes/PE1.png" alt="n1" width="800"/>

For example, there is a blue line corresponding to the tuple,

(age=35,educ=14,occ=102,sex=1,wageinc=100000,wkswrkd=52)

The frequencies are color-coded accoring to the legend at the right. So
the above tuple occurred something like 60 times in the data.

What about the difference between males and females (coded 1 and 2)?
One interesting point is that there seems to be greater range in the
men's salaries.  At the high end, though, men seem to have the edge.

Now, can that edge may be explained by differences between
the two groups in other variables?  For instance, do women tend to be in
lower-paying occupations?  To investigate that, let's move the **occ**
column to be adjacent to **wageinc**.

This is accomplished by a mouse operation that is provided by **plotly**,
the graphical package on top of which **cdparcoord** is built.
Specifically, we can use the mouse to drag the **occ** label to the
right, releasing the mouse when the column reaches near the **wageinc**
column.  The result is

<img src="vignettes/PE2.png" alt="n1" width="800"/>

Again, there is a range for each occupation. However, looking at the
more-frequent lines, occupation 102 seems to rather lucrative (and
possibly 140 and 141).  And if so, that seems to be bad news for the
women, as occupation 102 seems more populated by men.  On the other
hand, this might help explain the high-end salary gap found above.
Another possible piece of evidence in this direction is that the graph
seems to say the men tend to have higher levels of education.

To obtain a somehwat finer look, we can use another feature supplied by
**plotly**, a form of *brushing*. Here we highlight the women's lines by
using the mouse to drag the top of the **sex** column down slightly.
This causes the men's lines to go to light gray, while the women's lines
stay in color:

<img src="vignettes/PE3.png" alt="n1" width="800"/>

The fact that we requested brushing for **sex** = 2 is confirmed in the
graph by the appearance of a short magenta-colored line segment just
below the 2 tick mark.

Multiple columns can be brushed together.  To turn off brushing, click
and drag on a non-magenta portion of the axis.

# Example

Here we try the [Stanford WordBank
data](http://wordbank.stanford.edu/analyses?name=instrument_data) on
vocabulary acquisition in children.  The file used was **English.csv**,
from which we have a data frame **wb**, consisting of about 5500 rows.
(There are many NA values, though, and only about 2800 complete cases.)

```R
wb <- wb[,c(2,5,7,8,10)] 
wb <- discretize(wb,nlevels=5) 
discparcoord(wb,k=100) 
```

We again asked for 5 levels for each variable.  As noted in the Tips
section below, though, **cdparcoord**, like any graphical exploratory
tool, is best used by trying a number of different parameter
combinations, e.g.  varying **nlevels** here.

This produces

<img src="vignettes/WB1.png" alt="n1" width="800"/>

Nice -- but, presuming that **mom\_ed** has an ordinal relation with
vocabulary, the ordering of the labels here is not what we would like.
We can use **reOrder** to remedy that:

```R
wb <- reOrder(wb,'mom_ed',
   c('Secondary','Some College','College','Some Graduate','Graduate'))
discparcoord(wb,k=100)
```

<img src="vignettes/WB2.png" alt="n1" width="800"/>

By the way, there were further levels in the **mom\_ed** variable,
'Primary' and 'Some Secondary', but they didn't show up here, as we
plotted only the top 100 lines. (Or we set **nlevels** at a higher value
that could be tolerated by this data.) There was a similar issue with
missing levels on **birth\_order**.

Speaking of the latter, the earlier-born children seem to be at an
advantage, at least in the two orders that show up here.

Now suppose we wish to study girls with mothers having at least a
college education. Again we can use brushing, this time with two
variables **sex** and **mom\_ed** together, and several values together
in the latter variables: 

<img src="vignettes/WB3.png" alt="n1" width="800"/>

The magenta highlights show that **sex** and **mom\_ed** were brushed,
and in the latter case, specifically the levels 'College', 'Some Graduate' and
'Graduate'.  Lines with all other combinations now appear in light gray.

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

Had we wanted to handle **Height** separately, we could have called
**discretize()** twice:

```R
inpt <- list(inp2,inp3) 
m1 <- discretize(m,inpt) 
m2 <- discretize(m1) 
discparcoord(m2,k=150) 
```

### Accounting for NA Values

(EXPERIMENTAL)

R and R packages typically leave out any rows with NA
values. Unfortunately for data sets with high NA counts, this may have
drastic effects, such as low counts and possible bias. 
[`cdparcoord`](https://github.com/matloff/cdparcoord) addresses this
issue by allowing these rows to partially contribute to overall counts.
See the **NAexp** variable in **partialNA()**.

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

* Like any exploratory graphical tool, **cdparcoord** is best used by
  trying various parameter values, e.g. different values of **k**,
  **nlevels** and so on.

* Sometimes labels greatly hinder the visibility and clarity of the
  plot. This can be circumvented by opting to remove labels in plot.

* If the lines are all green, this means the frequencies are all the
  same, likely 1. In such case, use **discretize()** with a small value
  of **nlevels**.

* Sometimes two lines will coincide in one or more segments.  Brushing
  may help separate them.

# Authors

Norm Matloff, Harrison Nguyen, Vincent Yang
