skills_by_character =
    d:
        name: 'dig',
        details: 
            r:
                name: 'result'
            s:
                name: 'side'
    h:
        name: 'hit'
        details:
            h:
                name: 'hands'
            l:
                name: 'location'
            s:
                name: 'set'
            r:
                name: 'result'
    s:
        name: 'serve'
        details:
            t:
                name: 'type'
            f:
                name: 'from'
            l:
                name: 'location'
            d:
                name: 'deep'
            r: 
                name: 'result'
    set:
        name: 'set'
        details: {}
    p:
        name: 'pass'
        details:
            r:
                name: 'result'
            s:
                name: 'side'    
    b:
        name: 'block'
        details: 
            r:
                name: 'result'

skills = {}
for character, skill of skills_by_character
    skill.character = character
    skill.details.r = {name: 'result'}
    skills[skill.name] = skill

 (window ? module.exports).globals = {skills_by_character, skills}

