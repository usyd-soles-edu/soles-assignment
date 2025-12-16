(function () {
  'use strict';
  
  console.log('[learnr-sections] Script loaded');

  // Store sections globally for TOC handler access
  let globalSections = [];
  let currentRevealedIndex = -1;

  function getMainEl() {
    return (
      document.querySelector('main.content') ||
      document.querySelector('main') ||
      document.querySelector('#quarto-content') ||
      document.body
    );
  }

  function getTopLevelSections(mainEl) {
    const allLevel2 = Array.from(mainEl.querySelectorAll('section.level2'));
    return allLevel2.filter((section) => {
      const parentLevel2 = section.parentElement
        ? section.parentElement.closest('section.level2')
        : null;
      return parentLevel2 == null;
    });
  }

  function clamp(n, min, max) {
    return Math.max(min, Math.min(max, n));
  }

  function revealUpTo(sections, indexInclusive) {
    console.log('[learnr-sections] Revealing up to index', indexInclusive);
    
    // Update our tracking variable
    currentRevealedIndex = indexInclusive;
    
    sections.forEach((section, idx) => {
      if (idx <= indexInclusive) {
        section.classList.add('lr-visible');
        // Use grid for page-columns sections, block otherwise
        if (section.classList.contains('page-columns')) {
          section.style.display = 'grid';
        } else {
          section.style.display = 'block';
        }
      } else {
        section.classList.remove('lr-visible');
        section.style.display = 'none';
      }
    });

    // Update button states and visibility - only show button on the last revealed section
    sections.forEach((section, idx) => {
      const controls = section.querySelector('.lr-controls');
      if (!controls) return;
      
      const btn = controls.querySelector('.lr-next');
      if (!btn) return;
      
      const isLast = idx === sections.length - 1;
      btn.disabled = isLast;
      btn.setAttribute('aria-disabled', String(isLast));
      
      // Only show the button container on the last revealed section
      if (idx === indexInclusive && !isLast) {
        controls.style.display = 'flex';
      } else {
        controls.style.display = 'none';
      }
    });

    // Update TOC link states - do this and then force it again after a tiny delay
    // to override any native Quarto TOC highlighting
    updateTocLinkStates(sections, indexInclusive);
    setTimeout(function() {
      updateTocLinkStates(sections, indexInclusive);
    }, 50);
  }

  function updateTocLinkStates(sections, revealedUpToIndex) {
    const tocById = document.getElementById('TOC');
    if (!tocById) return;
    
    // Clear all active states first
    const allLinks = tocById.getElementsByTagName('a');
    for (let i = 0; i < allLinks.length; i++) {
      allLinks[i].classList.remove('active');
    }
    
    // Find the TOC link for the currently revealed section and mark it active
    if (revealedUpToIndex >= 0 && revealedUpToIndex < sections.length) {
      const currentSection = sections[revealedUpToIndex];
      const sectionId = currentSection.id;
      if (sectionId) {
        for (let i = 0; i < allLinks.length; i++) {
          const link = allLinks[i];
          if (link.hash === '#' + sectionId) {
            link.classList.add('active');
            break;
          }
        }
      }
    }
  }

  function addNextButtons(sections) {
    sections.forEach((section, idx) => {
      // Skip the last section - no next button needed
      if (idx === sections.length - 1) return;

      // Avoid duplicates if Quarto rehydrates content
      if (section.querySelector('.lr-controls')) return;

      const controls = document.createElement('div');
      controls.className = 'lr-controls';

      const nextBtn = document.createElement('button');
      nextBtn.type = 'button';
      nextBtn.className = 'btn btn-primary lr-next';
      nextBtn.textContent = 'Next';
      nextBtn.addEventListener('click', function() {
        const nextIndex = clamp(idx + 1, 0, sections.length - 1);
        revealUpTo(sections, nextIndex);
        sections[nextIndex].scrollIntoView({ behavior: 'smooth', block: 'start' });
      });

      // Add descriptive text beside the button
      const helperText = document.createElement('span');
      helperText.className = 'lr-helper-text';
      helperText.textContent = 'Continue →';
      helperText.setAttribute('aria-label', 'Click to continue');

      controls.appendChild(helperText);
      controls.appendChild(nextBtn);
      section.appendChild(controls);
    });
  }

  function findSectionIndexForTarget(sections, targetId) {
    const targetEl = document.getElementById(targetId);
    if (!targetEl) {
      console.log('[learnr-sections] Target not found:', targetId);
      return -1;
    }
    
    // Check if target itself is a level2 section
    for (let i = 0; i < sections.length; i++) {
      if (sections[i].id === targetId) {
        return i;
      }
    }
    
    // Check if target is inside a level2 section
    const parentSection = targetEl.closest('section.level2');
    if (parentSection) {
      for (let i = 0; i < sections.length; i++) {
        if (sections[i] === parentSection || sections[i].contains(parentSection)) {
          return i;
        }
      }
    }
    
    return -1;
  }

  function setupTocNavigation(sections) {
    // Debug: check what's in the document
    const tocById = document.getElementById('TOC');
    
    if (!tocById) {
      console.log('[learnr-sections] No TOC found');
      return;
    }
    
    // Use getElementsByTagName and filter by link.hash property (the URL fragment)
    const allLinks = tocById.getElementsByTagName('a');
    const tocLinks = [];
    
    for (let i = 0; i < allLinks.length; i++) {
      const link = allLinks[i];
      // Use the .hash property which gives us "#section-id" directly
      if (link.hash && link.hash.length > 1) {
        tocLinks.push(link);
      }
    }
    
    console.log('[learnr-sections] Found', tocLinks.length, 'TOC links with hash fragments');
    
    if (!tocLinks.length) {
      return;
    }
    
    tocLinks.forEach(function(link) {
      // Use capture phase to intercept before Quarto's handlers
      link.addEventListener('click', function(e) {
        // Use link.hash which gives "#section-id"
        const hash = link.hash;
        if (!hash || hash.length < 2) return;
        
        const targetId = hash.slice(1); // Remove the leading #
        console.log('[learnr-sections] TOC click:', targetId);
        
        const sectionIndex = findSectionIndexForTarget(sections, targetId);
        console.log('[learnr-sections] Section index:', sectionIndex);
        
        if (sectionIndex === -1) return;
        
        // Stop the event from propagating
        e.preventDefault();
        e.stopPropagation();
        
        // Reveal all sections up to and including this one
        revealUpTo(sections, sectionIndex);
        
        // Scroll to the target
        const targetEl = document.getElementById(targetId);
        if (targetEl) {
          setTimeout(function() {
            targetEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }, 100);
        }
        
        return false;
      }, true); // Use capture phase
    });
  }

  function init() {
    console.log('[learnr-sections] Initializing...');

    // Check if progressive sections is enabled
    // Try multiple ways to get the setting
    let isEnabled = true; // default

    // Method 1: Check window variable set by inline script
    if (typeof window.QUARTO_PROGRESSIVE_SECTIONS !== 'undefined') {
      isEnabled = window.QUARTO_PROGRESSIVE_SECTIONS !== false;
    }

    // Method 2: Check for data attribute on body
    if (document.body.dataset.progressiveSections) {
      isEnabled = document.body.dataset.progressiveSections !== 'false';
    }

    console.log('[learnr-sections] Progressive sections enabled:', isEnabled);

    if (!isEnabled) {
      console.log('[learnr-sections] Progressive sections disabled via YAML');
      // When disabled, show all sections (override the CSS hiding)
      const mainEl = getMainEl();
      const sections = getTopLevelSections(mainEl);
      sections.forEach(function(section) {
        section.classList.add('lr-disabled');
        if (section.classList.contains('page-columns')) {
          section.style.display = 'grid';
        } else {
          section.style.display = 'block';
        }
      });
      return;
    }

    const mainEl = getMainEl();
    const sections = getTopLevelSections(mainEl);
    globalSections = sections;

    console.log('[learnr-sections] Found', sections.length, 'level-2 sections');
    sections.forEach(function(s, i) {
      console.log('[learnr-sections]   Section', i, ':', s.id);
    });

    // If the page has no level-2 sections, do nothing.
    if (!sections.length) {
      console.log('[learnr-sections] No sections found, exiting');
      return;
    }

    // Hide all sections via inline style immediately
    sections.forEach(function(section) {
      section.style.display = 'none';
    });

    addNextButtons(sections);

    // Handle TOC link clicks - try immediately, then retry after delays
    // (Quarto may be processing the TOC asynchronously)
    setupTocNavigation(sections);
    setTimeout(function() { setupTocNavigation(sections); }, 100);
    setTimeout(function() { setupTocNavigation(sections); }, 500);
    setTimeout(function() { setupTocNavigation(sections); }, 1000);

    // Always start with only the first level-2 section visible.
    revealUpTo(sections, 0);
    
    // Disable Quarto's native TOC scroll highlighting and use our own
    // This prevents Quarto from highlighting other sections based on scroll
    document.addEventListener('scroll', function() {
      // Re-enforce our TOC highlighting based on what we've revealed, not scroll position
      if (currentRevealedIndex >= 0) {
        updateTocLinkStates(sections, currentRevealedIndex);
      }
    }, true);
    
    console.log('[learnr-sections] Done - first section should now be visible');
  }

  // Run immediately if DOM already loaded, otherwise wait
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    // DOM already loaded, run now
    init();
  }
})();
