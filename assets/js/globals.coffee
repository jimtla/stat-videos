skills_by_character =
    d:
        name: 'dig',
        details: {}
    h:
        name: 'hit'
        details:
            h:
                name: 'hands'
            l:
                name: 'location'
            s:
                name: 'set'
    s:
        name: 'serve'
        details:
            t:
                name: 'type'
            f:
                name: 'from'
            l:
                name: 'location'
    set:
        name: 'set'
        details: {}
    p:
        name: 'pass'
        details: {}
    b:
        name: 'block'
        details: {}

skills = {}
for character, skill of skills_by_character
    skill.character = character
    skill.details.r = {name: 'result'}
    skills[skill.name] = skill

 (window ? module.exports).globals = {skills_by_character, skills}

