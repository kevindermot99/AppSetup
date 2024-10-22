#!/bin/bash

echo -n "Project name: "
read project_name
echo -n "Install & Configure Vite App? (y/n) "
read vite
echo -n "Install Tailwind CSS? (y/n) "
read css
echo -n "Install Base Packages? (y/n) "
read packages
echo -n "Create Routes (y/n) "
read routes

cd "$HOME/Desktop"
mkdir "$project_name" 2>/dev/null
cd "$project_name" || exit  # Exit if the directory change fails

git init > /dev/null 2>&1
touch README.md
echo "## $project_name" >> README.md

echo -e "✔ Project Created \n✔ Empty git Repo initialized \n✔ Added README file"

if [ "$vite" == "y" ]; then
    echo "Installing Vite..."
    npm create vite@latest . --template vanilla
    echo "✔ Vite installed"

    if [ "$css" == "y" ]; then
        echo "Installing Tailwind CSS..."
        npm install -D tailwindcss postcss autoprefixer
        npx tailwindcss init -p
        echo "Tailwind CSS configuration created."
        echo "✔ Tailwind CSS installed"
    else
        echo "✖ Tailwind CSS installation skipped"
    fi
elif [ "$vite" == "n" ]; then
    echo "✖ Vite installation skipped"
else
    echo "Incorrect input for Vite installation"
fi

# Installing packages
if [ "$packages" == "y" ]; then
    npm install react-router-dom react-icons axios
    echo "✔ Installed react-router-dom"
    echo "✔ Installed react-icons"
    echo "✔ Installed axios"
fi

# Accept Routes
my_routes=()
if [ "$routes" == "y" ]; then
    echo -n "Enter route names (separated by spaces): "
    read -a my_routes
fi

# Create Routes
if [ "${#my_routes[@]}" -gt 0 ]; then
    # Ensure the src/pages directory exists
    mkdir -p src/pages

    # Prepare import statements and route definitions
    import_statements=""
    route_definitions=""

    # Make the first route in the array the "/" route
    first_route="${my_routes[0]}"
    
    # Create the first route file
    cat <<EOF > "src/pages/$first_route.jsx"
import React from 'react';

function $first_route() {
  return (
    <div>$first_route</div>
  );
}

export default $first_route;
EOF

    import_statements+="import $first_route from './pages/$first_route';"
    route_definitions+="<Route path=\"/\" element={<$first_route />} />"

    # Create remaining routes
    for i in "${my_routes[@]:1}"; do
        cat <<EOF > "src/pages/$i.jsx"
import React from 'react';

function $i() {
  return (
    <div>$i</div>
  );
}

export default $i;
EOF

        if [ $? -eq 0 ]; then
            echo "✔ Created src/pages/$i.jsx"
        else
            echo "✖ Failed to create src/pages/$i.jsx"
            exit 1
        fi

        import_statements+="import $i from './pages/$i';"
        route_definitions+="<Route path=\"/$i\" element={<$i />} />"
    done

    # Overwrite App.jsx with the new routes
    cat <<EOF > "src/App.jsx"
import { useState } from "react";
import "./App.css";
import { HashRouter, Route, Routes } from "react-router-dom";
$import_statements

function App() {
  return (
    <>
      <HashRouter>
        <Routes>
          $route_definitions
        </Routes>
      </HashRouter>
    </>
  );
}

export default App;
EOF

    echo "✔ Routes added to App.jsx"
fi


# Delete assets folder
if [ -d "src/assets" ]; then
    rm -rf src/assets
    echo "✔ Deleted assets folder"
fi

# Delete react.svg
if [ -f "src/assets/react.svg" ]; then
    rm src/assets/react.svg
    echo "✔ Deleted react.svg"
fi

# Delete vite.svg
if [ -f "public/vite.svg" ]; then
    rm public/vite.svg
    echo "✔ Deleted vite.svg"
fi

# Delete index.css
if [ -f "src/index.css" ]; then
    rm src/index.css
    echo "✔ Deleted index.css"
fi

# Remove 'import './index.css'' from main.jsx
if [ -f "src/main.jsx" ]; then
    sed -i.bak "/import '.\/index.css'/d" src/main.jsx
    echo "✔ Removed 'import ./index.css' from main.jsx"
fi

# Clear app.css and add Tailwind directives
if [ -f "src/App.css" ]; then
    echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > src/App.css
    echo "✔ Updated App.css with Tailwind directives"
fi

# Change title in public/index.html
if [ -f "public/index.html" ]; then
    sed -i.bak "s|<title>.*</title>|<title>$project_name</title>|" public/index.html
    echo "✔ Updated title in index.html to '$project_name'"
fi

# Replace contents of tailwind.config.js
if [ -f "tailwind.config.js" ]; then
    cat <<EOL > tailwind.config.js
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL
    echo "✔ Updated tailwind.config.js with new configuration"
fi

sleep 1
code .
