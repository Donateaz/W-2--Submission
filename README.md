# Project 1 - *Flicks*

**Flicks** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **12** hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [Tired, worked, but did not show graphics] User sees a loading state while waiting for the movies API.
- [Tired, worked, but did not show graphics] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [Tired, worked, but did not show graphics] User sees an error message when there's a networking error.
- [ ] Movies are displayed using a CollectionView instead of a TableView.
- [x] User can search for a movie.
- [ ] All images fade in as they are loading.
- [ ] Customize the UI.

The following **additional** features are implemented:

- [x] Clicking Search withdraws Keyboard but keeps filtered movies whereas clicking Cancel withdraws keyboard and shows all movies
- [Tired, worked, but did not show graphics] Once network error resolves, the network error view can withdrawn by clicking on it (part of optional feature) and also by pull-down refresh (additional feature). 

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Setting CollectionViewLayout values.
2. swift optionals, wrapping. unwrapping etc

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

![Video Walkthrough](MovieViewerWT.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.
1. Setting CollectionViewLayout values. I had to do a lot of hit & trial to get the right spacing.

## License

    Copyright [2016] [Donatea Zefi]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.# Flicks
